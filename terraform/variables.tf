variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "MyWebAppResourceGroup"
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  # --- FIX 3: Changed region to one with fewer provisioning restrictions ---
  default     = "West US 2"
}

variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
  default     = "MyWebAppVNet"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "The name of the subnet for the AKS cluster."
  type        = string
  default     = "AKSSubnet"
}

variable "aks_subnet_prefix" {
  description = "The address prefix for the AKS subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "db_subnet_name" {
  description = "The name of the subnet for the SQL database."
  type        = string
  default     = "DatabaseSubnet"
}

variable "db_subnet_prefix" {
  description = "The address prefix for the Database subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "MyWebAppAKSCluster"
}

variable "sql_admin_username" {
  description = "The administrator username for the SQL server."
  type        = string
  default     = "sqladmin"
}

variable "db_name" {
  description = "The name of the SQL database."
  type        = string
  default     = "MyWebAppDB"
}

variable "kv_name" {
  description = "The name of the Key Vault."
  type        = string
  # Key Vault names must be globally unique and alphanumeric.
  default     = "MyWebAppKeyVaultgitesh"
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
  default     = "MyWebAppServicePlan"
}

variable "app_service_name" {
  description = "The name of the App Service. Must be globally unique."
  type        = string
  default     = "my-web-app-gitesh-frontend" # Change 'gitesh' to make it unique
}

