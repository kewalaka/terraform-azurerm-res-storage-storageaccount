terraform {
  required_version = ">= 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2, < 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.1, < 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = false
}
