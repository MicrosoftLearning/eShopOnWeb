variable "environment_name" {
  description = "Name of the environment which is used to generate a short unique hash used in all resources"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Primary location for all resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = ""
}

variable "web_service_name" {
  description = "Name of the web service"
  type        = string
  default     = ""
}

variable "catalog_database_name" {
  description = "Name of the catalog database"
  type        = string
  default     = "catalogDatabase"
}

variable "catalog_database_server_name" {
  description = "Name of the catalog database server"
  type        = string
  default     = ""
}

variable "identity_database_name" {
  description = "Name of the identity database"
  type        = string
  default     = "identityDatabase"
}

variable "identity_database_server_name" {
  description = "Name of the identity database server"
  type        = string
  default     = ""
}

variable "app_service_plan_name" {
  description = "Name of the app service plan"
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Name of the key vault"
  type        = string
  default     = ""
}

variable "principal_id" {
  description = "Id of the user or app to assign application roles"
  type        = string
  default     = ""
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "app_user_password" {
  description = "Application user password"
  type        = string
  sensitive   = true
}