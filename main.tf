resource "random_password" "vmadmin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_virtual_network" "vnet01" {
  name                = "vnet01"
  resource_group_name = data.azurerm_resource_group.target_rg.name
  location            = data.azurerm_resource_group.target_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.target_rg.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "lbpip" {
  name                = "lbpip"
  location            = data.azurerm_resource_group.target_rg.location
  resource_group_name = data.azurerm_resource_group.target_rg.name
  allocation_method   = "Static"
  domain_name_label   = data.azurerm_resource_group.target_rg.name
}

resource "azurerm_lb" "testlb" {
  name                = "testlb"
  location            = data.azurerm_resource_group.target_rg.location
  resource_group_name = data.azurerm_resource_group.target_rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.testlb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "testlbprobe" {
  resource_group_name = data.azurerm_resource_group.target_rg.name
  loadbalancer_id     = azurerm_lb.testlb.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "testlbrule" {
  resource_group_name            = data.azurerm_resource_group.target_rg.name
  loadbalancer_id                = azurerm_lb.testlb.id
  name                           = "nginx-80-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.testlbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
}

resource "azurerm_linux_virtual_machine_scale_set" "webstack" {
  name                            = "webstack-vmss"
  resource_group_name             = data.azurerm_resource_group.target_rg.name
  location                        = data.azurerm_resource_group.target_rg.location
  sku                             = var.vm_sku
  instances                       = var.vmss_size
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = random_password.vmadmin_password.result

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = var.ubuntu_sku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = filebase64("${path.module}/custom_data.sh")

  network_interface {
    name    = "webstack"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
  }
}