##-----------------------------------------------------------------------------
## Versions
##-----------------------------------------------------------------------------
# Terraform version
terraform {
  required_version = ">= 1.14, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.64, < 8"
    }
  }
}