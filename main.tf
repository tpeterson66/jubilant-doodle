resource "azurerm_resource_group" "rg" {
  name     = "tpet66-rg-demo"
  location = "East US"
  tags = {budget = "$100"}
}