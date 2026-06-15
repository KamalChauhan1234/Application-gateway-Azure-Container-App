environment            = "prod"
location               = "East US"
resource_group_name    = "rg-appgw-prod"
app_gateway_name       = "appgw-prod"
container_app_name     = "containerapp-prod"
container_app_env_name = "cae-prod"
container_image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
vnet_name              = "vnet-prod"
appgw_subnet_name      = "snet-appgw-prod"
container_subnet_name  = "snet-container-prod"

tags = {
  Environment = "prod"
  Project     = "appgw-container"
  ManagedBy   = "terraform"
}
