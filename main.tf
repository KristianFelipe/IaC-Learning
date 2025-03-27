data "azurerm_client_config" "current" {}


###############################################
#                   ENV1                      #
###############################################


#Dette er VM1

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

  admin_password                  = azurerm_key_vault_secret.env1vm_password_secret.value
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

provisioner "local-exec" {
    command = "sudo apt install neofetch"
  }


}



###########################################
#                   NSG                   #
##########################################

resource "azurerm_network_security_group" "env1" {
  name                = "NSG-Allow-SSH"
  location            = azurerm_resource_group.env1.location
  resource_group_name = azurerm_resource_group.env1.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "env1" {
  network_interface_id      = azurerm_network_interface.env1.id
  network_security_group_id = azurerm_network_security_group.env1.id
}



#################################################
#                   Key Vault                   #
#################################################

resource "azurerm_key_vault" "env1" {
  name                      = "env1-keyvault"
  location                  = azurerm_resource_group.env1.location
  resource_group_name       = azurerm_resource_group.env1.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
}

# Generate random password
resource "random_password" "env1_vm_password" {
  length  = 20
  special = true
}


# Store password in Key Vault
resource "azurerm_key_vault_secret" "env1vm_password_secret" {
  name         = "env1-vm-admin-password"
  value        = random_password.env1_vm_password.result
  key_vault_id = azurerm_key_vault.env1.id
}


resource "azurerm_role_assignment" "env1" {
  principal_id         = "48d4d789-f15a-44a6-ba26-c0e232b82e41" # The object ID of the user, service principal, or group
  role_definition_name = "Key Vault Secrets User"                     # Role to assign
  scope                = azurerm_key_vault.env1.id              # The scope (could be a resource group, subscription, etc.)
}














###########################################
#                 ENV2                    #
##########################################

#Dette er VM2

###########################################
#                 Resource Group          #
###########################################


resource "azurerm_resource_group" "env2" {
  name     = "env2-resources"
  location = "West Europe"
}




##############################################
#                   Vnet and Subnet          #
##############################################

resource "azurerm_virtual_network" "env2" {
  name                = "env2-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.env2.location
  resource_group_name = azurerm_resource_group.env2.name
}

resource "azurerm_subnet" "env2" {
  name                 = "host-subnet"
  resource_group_name  = azurerm_resource_group.env2.name
  virtual_network_name = azurerm_virtual_network.env2.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "env2" {
  name                = "env2-public-ip"
  resource_group_name = azurerm_resource_group.env2.name
  location            = azurerm_resource_group.env2.location
  allocation_method   = "Static"
  sku                 = "Standard"
}




#########################################
#                   VM and NIC          # 
#########################################

resource "azurerm_network_interface" "env2" {
  name                = "vm-host-nic"
  location            = azurerm_resource_group.env2.location
  resource_group_name = azurerm_resource_group.env2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.env2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.env2.id
  }
}

resource "azurerm_linux_virtual_machine" "env2" {
  name                = "vm-host"
  resource_group_name = azurerm_resource_group.env2.name
  location            = azurerm_resource_group.env2.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.env2.id,
  ]

  admin_password                  = azurerm_key_vault_secret.env2vm_password_secret.value
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
  provisioner "local-exec" {
    command = "sudo apt install neofetch'"
  }
}






###########################################
#                   NSG                   #
##########################################

resource "azurerm_network_security_group" "env2" {
  name                = "NSG-Allow-SSH"
  location            = azurerm_resource_group.env2.location
  resource_group_name = azurerm_resource_group.env2.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "env2" {
  network_interface_id      = azurerm_network_interface.env2.id
  network_security_group_id = azurerm_network_security_group.env2.id
}



#################################################
#                   Key Vault                   #
#################################################

resource "azurerm_key_vault" "env2" {
  name                      = "env2-keyvault"
  location                  = azurerm_resource_group.env2.location
  resource_group_name       = azurerm_resource_group.env2.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
}

# Generate random password
resource "random_password" "env2_vm_password" {
  length  = 20
  special = true
}


# Store password in Key Vault
resource "azurerm_key_vault_secret" "env2vm_password_secret" {
  name         = "env2-vm-admin-password"
  value        = random_password.env2_vm_password.result
  key_vault_id = azurerm_key_vault.env2.id
}


resource "azurerm_role_assignment" "env2" {
  principal_id         = "48d4d789-f15a-44a6-ba26-c0e232b82e41" # The object ID of the user, service principal, or group
  role_definition_name = "Key Vault Secrets User"                     # Role to assign
  scope                = azurerm_key_vault.env2.id              # The scope (could be a resource group, subscription, etc.)
}



