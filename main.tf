provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.4.0"
  features {}
}

provider "azuread" {
  version = ">=0.6"
}

provider "kubernetes" {
  version = ">=1.9"
}

provider "random" {
  version = ">=2.2"
}

terraform {
    backend "azurerm" {}
}

