resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  resource_group_name = "${local.project}-webapp-rg"
  location            = var.location
  address_space       = var.cidr_vnet
  depends_on          = [azurerm_resource_group.rg_webapp]
}

resource "azurerm_subnet" "pendpoints_snet" {
  name                 = "${local.project}-pep-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = "${local.project}-webapp-rg"
  address_prefixes     = ["10.0.1.0/24"]
}
