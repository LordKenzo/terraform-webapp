resource "azurerm_user_assigned_identity" "my_acr_id" {
  name                = "myACRId"
  resource_group_name = azurerm_resource_group.rg_webapp.name
  location            = azurerm_resource_group.rg_webapp.location
}
