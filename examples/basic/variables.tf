variable "environment" {
  type    = string
  default = "dev"
}

variable "label_order" {
  type    = list(any)
  default = ["name", "environment"]
}

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID. Required."
}

variable "gcp_region" {
  type    = string
  default = "asia-south1"
}

variable "gcp_zone" {
  type    = string
  default = "asia-south1-a"
}