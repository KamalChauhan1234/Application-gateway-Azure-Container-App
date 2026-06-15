terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Backend config is passed via -backend-config flags in CI
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# ── Resource Group ──────────────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Networking ───────────────────────────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "appgw" {
  name                 = var.appgw_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "container" {
  name                 = var.container_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/23"]

  delegation {
    name = "containerAppDelegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ── Container App Module ─────────────────────────────────────────────────────
module "container_app" {
  source = "./modules/container-app"

  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  container_app_env_name = var.container_app_env_name
  container_app_name     = var.container_app_name
  container_image        = var.container_image
  environment            = var.environment
  subnet_id              = azurerm_subnet.container.id
  tags                   = var.tags
}

# ── Application Gateway Module ────────────────────────────────────────────────
module "app_gateway" {
  source = "./modules/app-gateway"

  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  app_gateway_name     = var.app_gateway_name
  environment          = var.environment
  subnet_id            = azurerm_subnet.appgw.id
  backend_fqdn         = module.container_app.container_app_fqdn
  tags                 = var.tags
}
