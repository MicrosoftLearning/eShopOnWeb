locals {
  resource_token = lower(substr(replace(uuid(), "-", ""), 0, 13))
  tags = {
    environment = var.environment_name
  }

  # Resource naming
  resource_group_name           = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.environment_name}"
  web_service_name              = var.web_service_name != "" ? var.web_service_name : "app-web-${local.resource_token}"
  app_service_plan_name         = var.app_service_plan_name != "" ? var.app_service_plan_name : "plan-${local.resource_token}"
  key_vault_name                = var.key_vault_name != "" ? var.key_vault_name : "kv-${local.resource_token}"
  catalog_database_server_name  = var.catalog_database_server_name != "" ? var.catalog_database_server_name : "sql-catalog-${local.resource_token}"
  identity_database_server_name = var.identity_database_server_name != "" ? var.identity_database_server_name : "sql-identity-${local.resource_token}"
}