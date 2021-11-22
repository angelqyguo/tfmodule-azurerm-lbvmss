resource "azurerm_resource_group" "test_rg" {
  name     = "test-stack-rg${var.uniqueid}"
  location = var.location
}

module "lb_vmss" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.test_rg.name
  depends_on = [
    azurerm_resource_group.test_rg
  ]
}