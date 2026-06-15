# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

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
  default     = null
  description = "GCP Project ID. Required."
}

variable "gcp_region" {
  type    = string
  default = "asia-south1"
}
