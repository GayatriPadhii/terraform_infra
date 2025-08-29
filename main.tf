terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {

  features {}
  subscription_id = "15cb3ee3-c143-4893-83fd-09a6efa7b01f"
}


data "azurerm_resource_group" "rg-name" {
  name = var.resource_group_name

}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg-name.name
}


data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.rg-name.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}


resource "azurerm_network_interface" "nic" {
  name                = "gayatri-nic"
  location            = data.azurerm_resource_group.rg-name.location
  resource_group_name = data.azurerm_resource_group.rg-name.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "WinVM-GayatriP"
  resource_group_name = data.azurerm_resource_group.rg-name.name
  location            = data.azurerm_resource_group.rg-name.location
  size                = "Standard_D2as_v5"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_id = "/subscriptions/92da1ef1-5469-4659-88df-e91ab8b5c0e0/resourceGroups/shared-images-rg/providers/Microsoft.Compute/galleries/amdocs_os_images/images/Windows2022/versions/1.0.052023"
}
