# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = local.tags
}

# Key Vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
    ]
  }

  # Access policy for the principal if provided
  dynamic "access_policy" {
    for_each = var.principal_id != "" ? [1] : []
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = var.principal_id

      secret_permissions = [
        "Get",
        "List",
      ]
    }
  }
}

# SQL Server for Catalog Database
resource "azurerm_mssql_server" "catalog" {
  name                          = local.catalog_database_server_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = "12.0"
  administrator_login           = "sqlAdmin"
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = local.tags
}

# Catalog Database
resource "azurerm_mssql_database" "catalog" {
  name         = var.catalog_database_name
  server_id    = azurerm_mssql_server.catalog.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "Basic"
  tags         = local.tags
}

# SQL Server for Identity Database
resource "azurerm_mssql_server" "identity" {
  name                          = local.identity_database_server_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = "12.0"
  administrator_login           = "sqlAdmin"
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = local.tags
}

# Identity Database
resource "azurerm_mssql_database" "identity" {
  name         = var.identity_database_name
  server_id    = azurerm_mssql_server.identity.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "Basic"
  tags         = local.tags
}

# SQL Server Firewall Rules - Allow Azure Services
resource "azurerm_mssql_firewall_rule" "catalog_azure" {
  name             = "Azure Services"
  server_id        = azurerm_mssql_server.catalog.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

resource "azurerm_mssql_firewall_rule" "identity_azure" {
  name             = "Azure Services"
  server_id        = azurerm_mssql_server.identity.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

# Store connection strings in Key Vault
resource "azurerm_key_vault_secret" "catalog_connection_string" {
  name         = "CatalogConnection"
  value        = "Server=${azurerm_mssql_server.catalog.fully_qualified_domain_name};Database=${azurerm_mssql_database.catalog.name};User Id=appUser;Password=${var.app_user_password};TrustServerCertificate=true"
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.tags

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "identity_connection_string" {
  name         = "IdentityConnection"
  value        = "Server=${azurerm_mssql_server.identity.fully_qualified_domain_name};Database=${azurerm_mssql_database.identity.name};User Id=appUser;Password=${var.app_user_password};TrustServerCertificate=true"
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.tags

  depends_on = [azurerm_key_vault.main]
}

# Store admin passwords in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sqlAdminPassword"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.tags

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "app_user_password" {
  name         = "appUserPassword"
  value        = var.app_user_password
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.tags

  depends_on = [azurerm_key_vault.main]
}

# Web App
resource "azurerm_linux_web_app" "web" {
  name                = local.web_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    minimum_tls_version = "1.2"
    ftps_state          = "FtpsOnly"
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "AZURE_KEY_VAULT_ENDPOINT"              = azurerm_key_vault.main.vault_uri
    "ConnectionStrings__CatalogConnection"  = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=CatalogConnection)"
    "ConnectionStrings__IdentityConnection" = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=IdentityConnection)"
    "UseOnlyInMemoryDatabase"               = "false"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
    application_logs {
      file_system_level = "Verbose"
    }
  }
}

# Give the web app access to Key Vault
resource "azurerm_key_vault_access_policy" "web_app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_linux_web_app.web.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.web.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
  ]

  depends_on = [azurerm_linux_web_app.web]
}