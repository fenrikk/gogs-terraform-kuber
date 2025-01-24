terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = var.eks_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.eks_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
    configs:
      params:
        server.insecure: true
    EOT
  ]

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
}

data "kubernetes_secret" "argocd_initial_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}

output "argocd_initial_password" {
  value     = data.kubernetes_secret.argocd_initial_password.data.password
  sensitive = true
}

resource "kubernetes_namespace" "project_ns" {
  metadata {
    name = "${var.project_name}"
  }
}

data "aws_secretsmanager_secret" "db_secrets" {
  name = var.aws_db_secrets_name
}

data "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id = data.aws_secretsmanager_secret.db_secrets.id
}

resource "kubernetes_secret" "db_secrets" {
  metadata {
    name      = "db-secrets"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }

  data = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)
}

resource "kubernetes_persistent_volume" "project_pv" {
  metadata {
    name = "${var.project_name}-pv"
  }
  spec {
    capacity = {
      storage = "${var.ebs_volume_size}Gi"
    }
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = var.ebs_volume_id
        fs_type   = "ext4"
      }
    }
    storage_class_name = var.ebs_volume_gp_type
  }
}

resource "kubernetes_persistent_volume_claim" "project_pvc" {
  metadata {
    name      = "${var.project_name}-pvc"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.ebs_volume_size}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.project_pv.metadata[0].name
    storage_class_name = var.ebs_volume_gp_type
  }
}

resource "kubernetes_config_map" "gogs_config" {
  metadata {
    name      = "gogs-config"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }

  data = {
    DOMAIN       = var.gogs_domain
    HTTP_PORT    = var.gogs_http_port
    DISABLE_SSH  = var.gogs_disable_ssh
    EXTERNAL_URL = "${var.gogs_protocol}://${var.gogs_domain}"
  }
}

resource "kubernetes_service" "gogs_postgres" {
  metadata {
    name      = "gogs-postgres"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port = 5432
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }

  spec {
    service_name = "gogs-postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:14"
          
          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "dbname"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "updated_db_secrets" {
  metadata {
    name      = "updated-db-secrets"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
  }

  data = {
    username = kubernetes_secret.db_secrets.data.username
    password = kubernetes_secret.db_secrets.data.password
    dbname   = kubernetes_secret.db_secrets.data.dbname
    endpoint = "gogs-postgres:5432"
  }

  depends_on = [kubernetes_stateful_set.postgres]
}

resource "kubernetes_ingress_v1" "gogs_ingress" {
  metadata {
    name      = "gogs-ingress"
    namespace = kubernetes_namespace.project_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=172800"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
      "alb.ingress.kubernetes.io/subnets"         = "subnet-054881acb41c3bba5, subnet-03ba8e0ed76018fb3"
    }
  }

  spec {
    rule {
      host = var.gogs_domain
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "gogs-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}