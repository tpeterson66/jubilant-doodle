locals {
  iaas_resource_group_name = "${var.env}-${var.location}-IaaS"
  paas_resource_group_name = "${var.env}-${var.location}-PaaS"
  iaas_vnet_name = "${var.env}-${var.location}-vNet"
  network_interface_name = "${var.env}-${var.location}-nic"
  virtual_machine_name = "${var.env}-${var.location}-vm"
  public_ip_name = "${var.env}-${var.location}-pip"
  network_security_group_name = "${var.env}-${var.location}-nsg"
}

module "resource_group" {
  source = "./modules/resource_group"
  name = local.iaas_resource_group_name
  location = "East US"
  tags = { budget = "$100" }
}

resource "azurerm_public_ip" "pip" {
  count = 2
  name                = "${local.public_ip_name}-${(count.index + 1)}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  allocation_method   = "Static"

  tags = module.resource_group.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.iaas_vnet_name
  address_space       = ["10.172.192.0/23"]
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags = module.resource_group.tags
}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = module.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.172.192.0/24"]
}

resource "azurerm_network_interface" "nic" {
  count = 2
  name                = "${local.network_interface_name}-${(count.index + 1)}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 2
  name                = "${local.virtual_machine_name}-${(count.index + 1)}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  provisioner "file" {
    source      = "./startup.sh"
    destination = "./startup.sh"
    connection {
      type     = "ssh"
      user     = "adminuser"
      private_key = file("~/.ssh/id_rsa")
      host     = azurerm_public_ip.pip[count.index].ip_address
    }
  }

    provisioner "remote-exec" {
    inline = [
      "chmod +x ./startup.sh",
      "./startup.sh",
    ]
    connection {
      type     = "ssh"
      user     = "adminuser"
      private_key = file("~/.ssh/id_rsa")
      host     = azurerm_public_ip.pip[count.index].ip_address
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  security_rule {
    name                       = "Tom's Home"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "162.197.55.204/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}