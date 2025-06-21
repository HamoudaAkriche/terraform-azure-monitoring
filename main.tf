resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {

  test       = "automatisation"
}
}

resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "log-workspace-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app_insights" {
  name                = "appinsights-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.monitoring.id
  }

  resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-monitoring"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "main_nic" {
  name                = "nic-monitoring"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_monitoring" {
  name                = "vm-monitoring"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  disable_password_authentication = true

admin_ssh_key {
  username   = var.admin_username
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFbmRrvPF1wlpHIoJpaokAVA5co+U6PDLIaPXch97+QZN/i2Crbq6cbWOy074KVwP6cpCTrn6qSW/OCmuaWPqQxZlJYltgGnbr4hSChHaBcvBCFEF0B7Fv7RsUwJIuASVZtcZKcRVZ/4vRXEKfZliaB3triweeppxPP+W2VE8Gxq/jLmD1u3CGus0ypEeFCHBOA+/rolOb8JxHgHeQjiF17/I2Q6xQjfhvXLmSlRkYD9KgS0vG2OMujZeHv/+bIN6FxrgUd0Zj4OIYXDjC2YK5hOJ6I/jyRxq0QAwJd3JQZNs1ks6hNtlnm8h+nybV+ojeVf1ndOTcOGZfGQZoSsRF"
}

   

  network_interface_ids = [
    azurerm_network_interface.main_nic.id
  ]

  os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
  version   = "latest"
}

}
resource "azurerm_virtual_machine_extension" "oms" {
  name                 = "OmsAgentForLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm_monitoring.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.0"

  settings = jsonencode({
    "workspaceId" = azurerm_log_analytics_workspace.monitoring.workspace_id
  })

  protected_settings = jsonencode({
    "workspaceKey" = azurerm_log_analytics_workspace.monitoring.primary_shared_key
  })
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



resource "azurerm_network_security_group" "nsg_ssh" {
  name                = "nsg-ssh"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.main_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_ssh.id
}


