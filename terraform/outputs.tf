output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "web_app_name" {
  description = "Name of the web application"
  value       = azurerm_linux_web_app.web.name
}

output "web_app_url" {
  description = "URL of the web application"
  value       = "https://${azurerm_linux_web_app.web.default_hostname}"
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "catalog_database_server_name" {
  description = "Name of the catalog database server"
  value       = azurerm_mssql_server.catalog.name
}

output "catalog_database_name" {
  description = "Name of the catalog database"
  value       = azurerm_mssql_database.catalog.name
}

output "identity_database_server_name" {
  description = "Name of the identity database server"
  value       = azurerm_mssql_server.identity.name
}

output "identity_database_name" {
  description = "Name of the identity database"
  value       = azurerm_mssql_database.identity.name
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.main.name
}

output "web_app_principal_id" {
  description = "Principal ID of the web app managed identity"
  value       = azurerm_linux_web_app.web.identity[0].principal_id
}