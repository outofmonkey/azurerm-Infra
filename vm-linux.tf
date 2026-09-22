# =========================================================
# PUBLIC IP - VM01
# =========================================================

resource "azurerm_public_ip" "vm01_public_ip" {
  name                = "vm01-public-ip"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  allocation_method = "Static"
  sku               = "Standard"
}

# =========================================================
# PUBLIC IP - VM02
# =========================================================

resource "azurerm_public_ip" "vm02_public_ip" {
  name                = "vm02-public-ip"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  allocation_method = "Static"
  sku               = "Standard"
}

# =========================================================
# NETWORK INTERFACE - VM01
# =========================================================

resource "azurerm_network_interface" "vniccard01" {
  name                = "nic-vmnodebot1"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm01_public_ip.id
  }
}

# =========================================================
# NETWORK INTERFACE - VM02
# =========================================================

resource "azurerm_network_interface" "vniccard02" {
  name                = "nic-vmnodebot2"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm02_public_ip.id
  }
}

# =========================================================
# LINUX VM - VM01
# =========================================================

resource "azurerm_linux_virtual_machine" "vlinux01" {
  name                = "debbot01"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  size = "Standard_B2s"
  network_interface_ids = [
    azurerm_network_interface.vniccard01.id
  ]

  # -------------------------------------------------------
  # SSH Key / Username and Password
  # -------------------------------------------------------
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  # -------------------------------------------------------
  # OS Disk
  # -------------------------------------------------------

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # -------------------------------------------------------
  # Ubuntu 22.04
  # -------------------------------------------------------

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # -------------------------------------------------------
  # User Data / Cloud-Init
  # -------------------------------------------------------

  custom_data = filebase64("${path.module}/user-data.sh")
}

# =========================================================
# LINUX VM - VM02
# =========================================================

resource "azurerm_linux_virtual_machine" "vlinux02" {
  name                = "debbot02"
  location            = data.azurerm_resource_group.resgroup.location
  resource_group_name = data.azurerm_resource_group.resgroup.name

  size = "Standard_B2s"


  network_interface_ids = [
    azurerm_network_interface.vniccard02.id
  ]

  # -------------------------------------------------------
  # SSH Key / Username and Password
  # -------------------------------------------------------
  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false


  # -------------------------------------------------------
  # OS Disk
  # -------------------------------------------------------

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # -------------------------------------------------------
  # Ubuntu 22.04
  # -------------------------------------------------------

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # -------------------------------------------------------
  # User Data / Cloud-Init
  # -------------------------------------------------------

  custom_data = filebase64("${path.module}/user-data.sh")
}

