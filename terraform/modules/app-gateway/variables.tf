variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "app_gateway_name"    { type = string }
variable "environment"         { type = string }
variable "subnet_id"           { type = string }
variable "backend_fqdn"        { type = string }
variable "tags"                { type = map(string); default = {} }
