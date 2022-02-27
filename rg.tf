provider "azurerm" {
  features {}

}
resource "azurerm_public_ip" "example" {
  name                = "mypip"
  resource_group_name = "myrg"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_public_ip.example.location
  resource_group_name = data.azurerm_public_ip.example.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = data.azurerm_public_ip.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = data.azurerm_public_ip.example.location
  resource_group_name = data.azurerm_public_ip.example.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = data.azurerm_public_ip.example.id
  }
}
resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = data.azurerm_public_ip.example.resource_group_name
  location            = data.azurerm_public_ip.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

output "virtual_machine_id" {
  value = azurerm_windows_virtual_machine.example.id
}
