resource "azurerm_resource_group" "rg_webapp" {
  name     = "${local.project}-webapp-rg"
  location = var.location
}
