data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg_acr" {
  name = "lorenzo-d-container-registry-rg"
}

data "azurerm_container_registry" "acr" {
  name                = "lorenzopcommonacr"
  resource_group_name = data.azurerm_resource_group.rg_acr.name
  # location            = azurerm_resource_group.rg_acr.location
}


data "azurerm_user_assigned_identity" "control_room_wa_identity" {
  name                = azurerm_linux_web_app.control_room_wa.identity[0].principal_id
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
}
