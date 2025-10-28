provider "azurerm" {
  features {}

  subscription_id = "<Subscription-ID>"
}

resource "azurerm_resource_group" "n8n_rg" {
  name     = "n8n-rg01"
  location = "Central India"
}

resource "azurerm_virtual_network" "n8n_vnet" {
  name                = "n8n-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name
}

resource "azurerm_subnet" "n8n_subnet" {
  name                 = "n8n-subnet"
  resource_group_name  = azurerm_resource_group.n8n_rg.name
  virtual_network_name = azurerm_virtual_network.n8n_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "n8n_nic" {
  name                = "n8n-nic"
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.n8n_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.n8n_public_ip.id
  }
}

resource "azurerm_network_security_group" "n8n_nsg" {
  name                = "n8n-nsg"
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.n8n_rg.name
  network_security_group_name = azurerm_network_security_group.n8n_nsg.name
}

resource "azurerm_network_security_rule" "n8n_rule" {
  name                        = "Allow-n8n"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5678"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.n8n_rg.name
  network_security_group_name = azurerm_network_security_group.n8n_nsg.name
}

resource "azurerm_network_security_rule" "https_rule" {
  name                        = "Allow-HTTPS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.n8n_rg.name
  network_security_group_name = azurerm_network_security_group.n8n_nsg.name
}

resource "azurerm_network_security_rule" "http_rule" {
  name                        = "Allow-HTTP"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.n8n_rg.name
  network_security_group_name = azurerm_network_security_group.n8n_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "n8n_nsg_assoc" {
  subnet_id                 = azurerm_subnet.n8n_subnet.id
  network_security_group_id = azurerm_network_security_group.n8n_nsg.id
}

resource "azurerm_public_ip" "n8n_public_ip" {
  name                = "n8n-public-ip"
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  domain_name_label   = "<domain-label-name>"
}

resource "azurerm_linux_virtual_machine" "n8n_vm" {
  name                = "n8n-LinuxVM"
  resource_group_name = azurerm_resource_group.n8n_rg.name
  location            = azurerm_resource_group.n8n_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.n8n_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
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

  custom_data = filebase64("cloud-init.yaml")
}