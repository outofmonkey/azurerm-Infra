terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------

resource "azurerm_resource_group" "resgroup" {
  name     = "my-resource-group"
  location = "Central India"
}

# ---------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = azurerm_resource_group.resgroup.location
  resource_group_name = azurerm_resource_group.resgroup.name

  address_space = ["172.168.0.0/20"]
}

# ---------------------------------------------------------
# Subnet
# ---------------------------------------------------------

resource "azurerm_subnet" "psubnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.resgroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["172.168.0.0/24"]
}

# ---------------------------------------------------------
# Network Interface
# ---------------------------------------------------------

resource "azurerm_network_interface" "vniccard" {
  name                = "nic-linux-vm"
  location            = azurerm_resource_group.resgroup.location
  resource_group_name = azurerm_resource_group.resgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ---------------------------------------------------------
# Linux Virtual Machine
# ---------------------------------------------------------

resource "azurerm_linux_virtual_machine" "vlinux" {
  name                = "debbot"
  location            = azurerm_resource_group.resgroup.location
  resource_group_name = azurerm_resource_group.resgroup.name

  size           = "Standard_D4_v3"
  admin_username = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.vniccard.id
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
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}