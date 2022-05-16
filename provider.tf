terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.6.0"
    }
  }
    backend "azurerm" {
      resource_group_name  = "tpeterson080621"
      storage_account_name = "tpeterson080621"
      container_name       = "jubilant-doodle"
      # key                  = var.backend_key
      key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

