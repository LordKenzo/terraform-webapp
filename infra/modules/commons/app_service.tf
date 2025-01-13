resource "azurerm_service_plan" "app_control_room" {

  name                = "${local.project}-plan-app-service-control-room"
  location            = azurerm_resource_group.rg_webapp.location
  resource_group_name = azurerm_resource_group.rg_webapp.name

  os_type  = "Linux"
  sku_name = "P1v2" #P1v2

  tags = var.tags
}

resource "azurerm_linux_web_app" "control_room_wa" {
  name                = format("%s-control-room-wa", local.project)
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  location            = azurerm_virtual_network.vnet.location
  service_plan_id     = azurerm_service_plan.app_control_room.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.my_acr_id.id]
  }

  app_settings = {
    WEBSITE_DNS_SERVER         = "168.63.129.16" # Server DNS Azure
    WEBSITE_STARTUP_FILE       = "npm start"     # Comando di startup
    WEBSITES_PORT              = 3000            # Porta NextJS
    SOME_KEY                   = "some-value"
    DOCKER_REGISTRY_SERVER_URL = "https://${data.azurerm_container_registry.acr.login_server}"
    DOCKER_ENABLE_CI           = "true"
    DOCKER_CUSTOM_IMAGE_NAME   = "${data.azurerm_container_registry.acr.login_server}/my-nextjs-app:latest"
  }

  site_config {
    always_on = true
  }

  tags = var.tags
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging-slot"
  app_service_id = azurerm_linux_web_app.control_room_wa.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.my_acr_id.id]
  }

  app_settings = {
    WEBSITE_DNS_SERVER         = "168.63.129.16" # Server DNS Azure
    WEBSITE_STARTUP_FILE       = "npm start"     # Comando di startup
    WEBSITES_PORT              = 3000
    SOME_KEY                   = "some-value"
    DOCKER_REGISTRY_SERVER_URL = "https://${data.azurerm_container_registry.acr.login_server}"
    DOCKER_ENABLE_CI           = "true"
    DOCKER_CUSTOM_IMAGE_NAME   = "${data.azurerm_container_registry.acr.login_server}/my-nextjs-app:latest"
  }

  site_config {
    always_on = true
  }
}

