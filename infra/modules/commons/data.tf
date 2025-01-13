data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg_acr" {
  name = "lorenzo-d-container-registry-rg"
}

data "azurerm_container_registry" "acr" {
  name                = "lorenzopcommonacr"
  resource_group_name = data.azurerm_resource_group.rg_acr.name
  # location            = azurerm_resource_group.rg_acr.location
}


