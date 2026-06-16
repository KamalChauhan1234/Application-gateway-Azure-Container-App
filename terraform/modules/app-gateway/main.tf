locals {
  sku_name = var.environment == "prod" ? "WAF_v2" : "Standard_v2"
  sku_tier = var.environment == "prod" ? "WAF_v2" : "Standard_v2"
  capacity = var.environment == "prod" ? 2 : 1
}

# Public IP for App Gateway frontend
resource "azurerm_public_ip" "main" {
  name                = "pip-${var.app_gateway_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku {
    name     = local.sku_name
    tier     = local.sku_tier
    capacity = local.capacity
  }
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  # WAF only for prod
  dynamic "waf_configuration" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      enabled          = true
      firewall_mode    = "Prevention"
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
    }
  }

  # ── Gateway IP config ───────────────────────────────────────────────────
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  # ── Frontend ──────────────────────────────────────────────────────────────
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  # ── Backend Pool (Azure Container App) ──────────────────────────────────
  backend_address_pool {
    name  = "container-app-pool"
    fqdns = [var.backend_fqdn]
  }

  # ── Backend HTTP Settings ────────────────────────────────────────────────
  backend_http_settings {
    name                                = "container-app-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true # Required for Container Apps
  }

  # ── HTTP Listener ────────────────────────────────────────────────────────
  http_listener {
    name                           = "appgw-listener-http"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  # ── Routing Rule ─────────────────────────────────────────────────────────
  request_routing_rule {
    name                       = "appgw-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-listener-http"
    backend_address_pool_name  = "container-app-pool"
    backend_http_settings_name = "container-app-http-settings"
    priority                   = 100
  }

  # ── Health Probe ─────────────────────────────────────────────────────────
  probe {
    name                                      = "container-app-probe"
    protocol                                  = "Http"
    path                                      = "/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }
}
