terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.24.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "689abbb8-e257-4b54-8bf7-3dc50ae46c77"
}