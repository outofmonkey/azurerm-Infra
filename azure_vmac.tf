
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

# =========================================================
# Resource Group
# =========================================================

data "azurerm_resource_group" "resgroup" {
  name = "kml_rg_main-42b879a69547485b"
}

# =========================================================
# Virtual Network
# =========================================================

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  address_space = ["172.168.0.0/20"]
}

# =========================================================
# Subnet
# =========================================================

resource "azurerm_subnet" "psubnet" {
  name                 = "public-subnet"
  resource_group_name  = data.data.azurerm_resource_group.resgroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["172.168.0.0/24"]
}

# =========================================================
# Network Security Group
# =========================================================

resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  # -------------------------------------------------------
  # HTTP
  # -------------------------------------------------------

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # -------------------------------------------------------
  # HTTPS
  # -------------------------------------------------------

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # -------------------------------------------------------
  # SSH
  # -------------------------------------------------------

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================================
# Associate NSG with Subnet
# =========================================================

resource "azurerm_subnet_network_security_group_association" "web_nsg_association" {
  subnet_id                 = azurerm_subnet.psubnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

