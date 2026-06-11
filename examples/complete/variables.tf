# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order for resource naming."
}

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID. No default — must be provided."
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Default GCP region."
}

variable "gcp_zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP zone."
}
