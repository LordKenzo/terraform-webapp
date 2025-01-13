resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.my_acr_id.principal_id

  depends_on = [
    azurerm_linux_web_app.control_room_wa
  ]
}
