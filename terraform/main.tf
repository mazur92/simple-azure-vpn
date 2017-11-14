provider "azurerm" {
  #Subject to change in variables.tf
  subscription_id = "${var.env["subscription_id"]}"
  client_id       = "${var.env["client_id"]}"
  client_secret   = "${var.env["client_secret"]}"
  tenant_id       = "${var.env["tenant_id"]}"
}

resource "azurerm_resource_group" "simple-azure-vpn-rgroup" {
  name     = "simpleAzureVPN"
  location = "${var.env["region"]}"

  tags {
    environment = "Simple Azure VPN"
  }
}

resource "azurerm_virtual_network" "simple-azure-vpn-vnet" {
  name                = "simpleAzureVPNVnet"
  address_space       = ["172.16.0.0/28"]
  location            = "${var.env["region"]}"
  resource_group_name = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"

  tags {
    environment = "Simple Azure VPN"
  }
}

resource "azurerm_subnet" "simple-azure-vpn-subnet" {
  name                 = "simpleAzureVPNSubnet"
  resource_group_name  = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.simple-azure-vpn-vnet.name}"
  address_prefix       = "172.16.0.0/29"
}

resource "azurerm_public_ip" "simple-azure-vpn-publicip" {
  name                         = "simpleAzureVPNPublicIP"
  location                     = "${var.env["region"]}"
  resource_group_name          = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Simple Azure VPN"
  }
}

resource "azurerm_network_security_group" "simple-azure-vpn-sg" {
  name                = "simpleAzureVPNSecGrp"
  location            = "${var.env["region"]}"
  resource_group_name = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VPN"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Simple Azure VPN"
  }
}

resource "azurerm_network_interface" "simple-azure-vpn-nic" {
  name                      = "simpleAzureVPNNIC"
  location                  = "${var.env["region"]}"
  resource_group_name       = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.simple-azure-vpn-sg.id}"

  ip_configuration {
    name                          = "simpleAzureVPNNICconfig"
    subnet_id                     = "${azurerm_subnet.simple-azure-vpn-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.simple-azure-vpn-publicip.id}"
  }

  tags {
    environment = "Simple Azure VPN"
  }
}

resource "azurerm_virtual_machine" "simple-azure-vpn-vm" {
  name                  = "simpleAzureVPNVM"
  location              = "${var.env["region"]}"
  resource_group_name   = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.simple-azure-vpn-nic.id}"]
  vm_size               = "${var.env["vm_size"]}"

  storage_os_disk {
    name              = "simple-azure-vpn-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myVPN"
    admin_username = "${var.env["admin_username"]}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.env["admin_username"]}/.ssh/authorized_keys"
      key_data = "${var.env["ssh_key"]}"
    }
  }

  tags {
    environment = "Simple Azure VPN"
  }
}

data "azurerm_public_ip" "simple-azure-vpn-ip-data" {
  name                = "${azurerm_public_ip.simple-azure-vpn-publicip.name}"
  resource_group_name = "${azurerm_resource_group.simple-azure-vpn-rgroup.name}"
  depends_on          = ["azurerm_virtual_machine.simple-azure-vpn-vm"]
}
