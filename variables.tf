variable "aws_region" {
  default = "eu-north-1"
}

variable "project_name" {
  description = "Project name"
  type = string
  default = "gogs"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "gogs-cluster"
}

variable "eks_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
  default     = "https://7EE1A856D3C558E89442B2FB7386A9B5.gr7.eu-north-1.eks.amazonaws.com"
}

variable "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJTHRGaDNjNjFEenN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBNU1qY3hNakkxTURkYUZ3MHpOREE1TWpVeE1qTXdNRGRhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNya0w5VW9jcGpWay9RR01mM0RpdWNWYnJKVFRPVVdiNDFCU3U1czIvaExXU09QUDFoalN0WHUwT2wKaVE4VGQvQWNSYkJPVFZYaFQ4UU4yNWY3bHJaa2NhanVkWjdhWllMbmNlN2RVZGZVV2VRSGlXNVNNc0cyKzBIaQpDZ0ZFTlBaNlN1RUJEeTduWGpENThtbGdRd2FSZUJFVGVhQ1lPZWJLeDkvU2FyaHJLTUdoU09FNmNqWWwyQmYwCkRBVmlwdkNjSVhDUlY4VEVtLzFkRlpldWRFU0p3aUdOVnpQOU9GTmRGdHU4OGpSQmg0U2pjcDVodFZSYU4yNGsKMlVoZk5iRHR2ZHpWUm45OHNaVlhUSURLT2tLdEJwSlk2ei8yVSsvdXRsbTFUTFpTYWtlR21EaFR2YllPMUJFeApRWlVXRm1EMHRGMTdQUXpIMzdVTTlXcTBpV2xSQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRaUpmNnRmWjd5VmpLU1lVdnZVcTR4c3pJZVp6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXUzTnU0VUhCQQpIby83c3Jad1FFSHdIS0p4QVBkcHNhTitaKzlDN0pkYktLN1ZWNFU1RXZvb1k0a0ZVK1hROGdOZzVCMHBCSXd2CjR2S1gwNnJwN3k0RytaSXdiQkVIeHMxVVkzUGN4NXBpZlVqTzVnOSt5K1FlQXVKaWtKSXVvWFZCS1lMZGlXSE4KK0JDUDJ1b2N4YVJuWk1XcmlQZUlZeDgvZHBqQTY2WW5MS2RjZnZ1cERPdVREc0Yvb2dUYzRMT0pZL3gvczZZWQpGVnZsWTBXN1NxQnRaOXVZaUVDRXVjM21oMlVHb3V4UjZqZE1IV0dRR3pDVE9XNHVOY3RuSnFGbk1Gd3BlR3cvClRuaU9LNzg4aCszTmZRTFRoUHhLUDdrZ05UcUJFZi9pbjFaSTZuRithZXltWFBEcUcxSGt4bCtad0NyMVhyTFMKcmJyU1E0TlIyUWpCCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
}

variable "aws_db_secrets_name" {
  description = "The name of the database secrets in AWS"
  type        = string
  default     = "gogs-rds-secrets"
}

variable "ebs_volume_id" {
  description = "The ID of EBS volume"
  type = string
  default = "vol-027ace91fc1e70253"
}

variable "ebs_volume_size" {
  description = "The size of EBS volume"
  type = number
  default = 20
}

variable "ebs_volume_gp_type" {
  description = "The type gp of EBS volume"
  type = string
  default = "gp3"
}

variable "gogs_domain" {
  description = "Domain for Gogs"
  type        = string
  default     = "gogs.pp.ua"
}

variable "gogs_http_port" {
  description = "HTTP port for Gogs"
  type        = string
  default     = "3000"
}

variable "gogs_disable_ssh" {
  description = "Disable SSH for Gogs"
  type        = string
  default     = "true"
}

variable "gogs_protocol" {
  description = "Protocol for Gogs external URL"
  type        = string
  default     = "http"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM sertificate"
  type = string
  default = "arn:aws:acm:eu-north-1:145023097801:certificate/56d6e86f-7278-4ac5-953b-764fca3c6dc8"
}