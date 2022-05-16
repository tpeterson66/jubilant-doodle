variable "name" {
  type = string
  description = "Name the resource group where everything will be stored"
}
variable "location" {
  type = string
  description = "resource location"
}
variable "tags" {
  # type = object
  description = "tags applied to resource"
}

resource "azurerm_resource_group" "rg" {
  name     = var.name # required
  location = var.location # required
  tags     = var.tags
}

output "location" {
  value = azurerm_resource_group.rg.location
}
output "name" {
  value = azurerm_resource_group.rg.name
}
output "tags" {
  value = azurerm_resource_group.rg.tags
}
output "id" {
  value = azurerm_resource_group.rg.id
}