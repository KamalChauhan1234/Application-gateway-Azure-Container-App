variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "container_app_env_name" { type = string }
variable "container_app_name"  { type = string }
variable "container_image"     { type = string }
variable "environment"         { type = string }
variable "subnet_id"           { type = string }
variable "tags"                { type = map(string); default = {} }
