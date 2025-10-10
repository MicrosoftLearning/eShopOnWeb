resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  blob_properties {
    versioning_enabled = true
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

resource "azurerm_storage_container" "container" {
  name                  = "eshoponweb-data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
