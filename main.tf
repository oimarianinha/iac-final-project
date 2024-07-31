# Generate resource group
resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# Create virtual network
resource "azurerm_virtual_network" "student-vnet" {
  name                = "student-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Create subnet
resource "azurerm_subnet" "student-subnet" {
  name                 = "student-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.student-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create network securtiy group
resource "azurerm_network_security_group" "student-nsg" {
  name                = "student-nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IP
resource "azurerm_public_ip" "student-pip" {
  name                = "student-pip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "student-nic" {
  name                = "student-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_configuration {
    name                          = "subnet-nic-configuration"
    subnet_id                     = azurerm_subnet.student-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.student-pip.id
  }
}

# Conecta NSG com as VMs
resource "azurerm_network_interface_security_group_association" "student-net-nsg" {
  network_interface_id      = azurerm_network_interface.student-nic.id
  network_security_group_id = azurerm_network_security_group.student-nsg.id
}

# Create VMs
resource "azurerm_linux_virtual_machine" "student-vm" {
  name                  = "student-vm"
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.student-nic.id]
  size                  = "Standard_DS1_v2"
  os_disk {
    name                 = "student-vm-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name  = "student-vm"
  admin_username = var.username
  admin_password = var.password

  depends_on = [ 
    azurerm_network_interface_security_group_association.student-net-nsg
  ]
}

# Generate inventory vms
resource "local_file" "inventory" {
  content = templatefile("inventory.tpl", {
    web_ip            = azurerm_linux_virtual_machine.student-vm.public_ip_address,
    ansible_user      = var.username
    ansible_password  = var.password
  })
  filename = "./ansible/inventory.ini"
}


