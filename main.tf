#############################################
#                   Resource group          #
#############################################

resource "azurerm_resource_group" "env1" {
  name     = "env1-resources"
  location = "West Europe"
}





##############################################
#                   Vnet and Subnet          #
##############################################

resource "azurerm_virtual_network" "env1" {
  name                = "env1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.env1.location
  resource_group_name = azurerm_resource_group.env1.name
}

resource "azurerm_subnet" "env1" {
  name                 = "host-subnet"
  resource_group_name  = azurerm_resource_group.env1.name
  virtual_network_name = azurerm_virtual_network.env1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "env1" {
  name                = "env1-public-ip"
  resource_group_name = azurerm_resource_group.env1.name
  location            = azurerm_resource_group.env1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  }




#########################################
#                   VM and NIC          #
#########################################

resource "azurerm_network_interface" "env1" {
  name                = "vm-host-nic"
  location            = azurerm_resource_group.env1.location
  resource_group_name = azurerm_resource_group.env1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.env1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.env1.id
  }
}

resource "azurerm_linux_virtual_machine" "env1" {
  name                = "vm-host"
  resource_group_name = azurerm_resource_group.env1.name
  location            = azurerm_resource_group.env1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.env1.id,
  ]

  admin_password                  = "Password5537!"
  disable_password_authentication = false


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
