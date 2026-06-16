resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.container_app_env_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "main" {
  name                       = var.container_app_env_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Internal VNet integration — App Gateway talks to it internally
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = true

  tags = var.tags
}

resource "azurerm_container_app" "main" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  template {
    container {
      name   = var.container_app_name
      image  = var.container_image
      cpu    = var.environment == "prod" ? 1.0 : 0.5
      memory = var.environment == "prod" ? "2Gi" : "1Gi"

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    }

    min_replicas = var.environment == "prod" ? 2 : 1
    max_replicas = var.environment == "prod" ? 10 : 3
  }

  ingress {
    external_enabled = false # Only accessible via App Gateway
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
