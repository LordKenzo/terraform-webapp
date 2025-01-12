resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.control_room_wa.identity[0].principal_id

  depends_on = [
    azurerm_linux_web_app.control_room_wa
  ]
}
