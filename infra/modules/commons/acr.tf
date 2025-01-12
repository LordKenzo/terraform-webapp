resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.control_room_wa.identity[0].principal_id

  depends_on = [
    azurerm_linux_web_app.control_room_wa
  ]
}


resource "azurerm_role_assignment" "acr_pull_role" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_virtual_network.vnet.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${data.azurerm_container_registry.acr.name}"
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.control_room_wa_identity.principal_id
}
