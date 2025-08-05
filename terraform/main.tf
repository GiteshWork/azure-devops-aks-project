terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# 1. Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Create a Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# 3. Create a Subnet for the AKS Cluster
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_prefix
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# 4. Create a Subnet for the Database
resource "azurerm_subnet" "db_subnet" {
  name                 = var.db_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.db_subnet_prefix
  service_endpoints    = ["Microsoft.Sql"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# 5. Create a Network Security Group (NSG) for the AKS Subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 6. Associate the NSG with the AKS Subnet
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
  depends_on = [
    azurerm_subnet.aks_subnet
  ]
}

# 7. Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  # --- FIX 1: Removed hyphen from random name to meet ACR naming requirements ---
  name                = replace("mywebappacr${random_pet.pet.id}", "-", "") # Must be globally unique and alphanumeric
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# 8. Create an Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = 1
    # --- FIX 2: Changed VM size to one that is allowed in the subscription ---
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  # --- FIX 4: Added network profile to prevent IP address conflicts ---
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16" # Use a non-overlapping IP range
    dns_service_ip = "10.1.0.10"
  }

  role_based_access_control_enabled = true
  
  depends_on = [
    azurerm_subnet_network_security_group_association.aks_nsg_assoc
  ]
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# 9. Create a SQL Server and Database
resource "random_pet" "pet" {
  length = 2
}

resource "random_string" "sql_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = "mywebapp-sqlserver-${random_pet.pet.id}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_string.sql_password.result
}

resource "azurerm_mssql_database" "db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "S0"
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql.id
  subnet_id = azurerm_subnet.db_subnet.id
  depends_on = [
    azurerm_mssql_server.sql,
    azurerm_subnet.db_subnet
  ]
}

# 10. Create an Azure Key Vault and store the DB connection string
resource "azurerm_key_vault" "kv" {
  name                      = var.kv_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  soft_delete_retention_days = 7
}

data "azurerm_client_config" "current" {}

# --- FIX 5: Add an access policy to give your user account permissions to the Key Vault ---
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  # Grant all permissions for secrets
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover"
  ]
}

resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${random_string.sql_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id

  # Ensure the access policy is created before trying to add a secret
  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]
}

# 11. Create an App Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1" # Free tier
}

# 12. Create the App Service for the frontend
resource "azurerm_linux_web_app" "app_service" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = false
  }
}


