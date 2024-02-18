@description('Generate a Suffix based on the Resource Group ID')
param suffix string = uniqueString(resourceGroup().id)

@description('Use the Resource Group Location')
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: 'cr${suffix}'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${suffix}'
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-${suffix}'
  location: location
  tags: {}
  properties: {
    siteConfig: {
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'UseOnlyInMemoryDatabase'
          value: 'true'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Docker'
        }
        {
          name: 'ASPNETCORE_HTTP_PORTS'
          value: '80'
        }
      ]
      linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/eshoponweb/web:latest'
    }
    serverFarmId: appServicePlan.id
  }
  identity: {
    type: 'SystemAssigned'
  }
}
