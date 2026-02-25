##-----------------------------------------------------------------------------
## Versions
##-----------------------------------------------------------------------------
# Terraform version
terraform {
  required_version = ">= 1.6.6"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=6.49.1"
    }
  }
}