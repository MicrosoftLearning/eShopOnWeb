@description('Name for the container group')
param name string = 'eshopcontainer'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Port to open on the container and the public IP address.')
param port int = 5106

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

@secure()
param password string

param username string

param server string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'

            }
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          environmentVariables: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Docker'
            }
            {
              name: 'UseOnlyInMemoryDatabase'
              value: 'true'
            }
            {
              name: 'ASPNETCORE_HTTP_PORTS'
              value: '80'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
    imageRegistryCredentials: [
      {
        password: password
        server: server
        username: username
      }
    ]
  }
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
