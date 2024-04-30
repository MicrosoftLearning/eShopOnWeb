@description('Generate a Suffix based on the Resource Group ID')
param suffix string = uniqueString(resourceGroup().id)

@description('Set the ACR Pull Role Definition ID')
param acrPullRoleDefinitionID string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

@description('Generate a unique GUID to use as name for the role assignment')
var webAppToAcrRoleAssignmentName = guid(webApp.id, acrPullRoleDefinitionID, acr.id)


resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'cr${suffix}'
}

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: 'app-${suffix}'
}

resource webAppToAcrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: webAppToAcrRoleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionID)
    principalId: webApp.identity.principalId
  }
}
