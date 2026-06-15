environment            = "dev"
location               = "East US"
resource_group_name    = "rg-appgw-dev"
app_gateway_name       = "appgw-dev"
container_app_name     = "containerapp-dev"
container_app_env_name = "cae-dev"
container_image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
vnet_name              = "vnet-dev"
appgw_subnet_name      = "snet-appgw-dev"
container_subnet_name  = "snet-container-dev"

tags = {
  Environment = "dev"
  Project     = "appgw-container"
  ManagedBy   = "terraform"
}
