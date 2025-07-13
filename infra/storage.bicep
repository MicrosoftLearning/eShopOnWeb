@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the storage account.')
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

output storageURI string = storageAccount.properties.primaryEndpoints.blob
