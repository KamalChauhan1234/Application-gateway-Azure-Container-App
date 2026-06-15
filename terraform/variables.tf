variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "container_app_name" {
  description = "Name of the Container App"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container app"
  type        = string
}

variable "container_app_env_name" {
  description = "Name of the Container App Environment"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "appgw_subnet_name" {
  description = "Subnet name for Application Gateway"
  type        = string
}

variable "container_subnet_name" {
  description = "Subnet name for Container App Environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
