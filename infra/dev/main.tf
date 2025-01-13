terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30, < 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.16.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "lorenzo-d-tf-rg"
    storage_account_name = "lorenzodsa"
    container_name       = "lorenzo-tfstate"
    key                  = "webapp.dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "commons" {
  source    = "../modules/commons" # sorgente del modulo
  prefix    = local.prefix         # valore prefix da passare al modulo
  env_short = local.env_short      # valore env_short da passare
  cidr_vnet = local.cidr_vnet
}
