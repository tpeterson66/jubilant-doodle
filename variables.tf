variable "resource_group_name" {
  type = string
  description = "Name the resource group where everything will be stored"
  # default = "tpet-dev-rg"
}

variable "env" {
  type = string
  description = "Local Environment Name"  
}

variable "location" {
  type = string
  description = "Location for services"
  default = "eastus"
}

# passed in via terraform.tfstate file
variable "vm_password" {}
variable "sql_password" {}

variable "vm_sku" {
  type = string
  description = "value"
  default = "Standard_d2vs3"
}