param website-name string = 'eshop-demo-alex'
param plan string = 'eshop-plan'

resource serverfarms_eshop_plan_name_resource 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: serverfarms_eshop_plan_name
  location: 'East US'
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource website-name_resource 'Microsoft.Web/sites@2022-09-01' = {
  name: website-name
  location: 'East US'
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${website-name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${website-name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_eshop_plan_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '4DCAA2A131E600A1A2FEF35513A4C0BCCCA0DF538A19697F4A828CF3271CC9B7'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource website-name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: website-name_resource
  name: 'ftp'
  location: 'East US'
  properties: {
    allow: false
  }
}

resource website-name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: website-name_resource
  name: 'scm'
  location: 'East US'
  properties: {
    allow: false
  }
}

resource website-name_web 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: website-name_resource
  name: 'web'
  location: 'East US'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v7.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$eshop-demo-alex'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource website-name_website-name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
  parent: website-name_resource
  name: '${website-name}.azurewebsites.net'
  location: 'East US'
  properties: {
    siteName: 'eshop-demo-alex'
    hostNameType: 'Verified'
  }
}

resource website-name_stage 'Microsoft.Web/sites/slots@2022-09-01' = {
  parent: website-name_resource
  name: 'stage'
  location: 'East US'
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'eshop-demo-alex-stage.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'eshop-demo-alex-stage.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_eshop_plan_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '4DCAA2A131E600A1A2FEF35513A4C0BCCCA0DF538A19697F4A828CF3271CC9B7'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource website-name_stage_ftp 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: website-name_stage
  name: 'ftp'
  location: 'East US'
  properties: {
    allow: false
  }
  dependsOn: [

    website-name_resource
  ]
}

resource website-name_stage_scm 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: website-name_stage
  name: 'scm'
  location: 'East US'
  properties: {
    allow: false
  }
  dependsOn: [

    website-name_resource
  ]
}

resource website-name_stage_web 'Microsoft.Web/sites/slots/config@2022-09-01' = {
  parent: website-name_stage
  name: 'web'
  location: 'East US'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v7.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$eshop-demo-alex__stage'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
  dependsOn: [

    website-name_resource
  ]
}

resource website-name_stage_website-name_stage_azurewebsites_net 'Microsoft.Web/sites/slots/hostNameBindings@2022-09-01' = {
  parent: website-name_stage
  name: '${website-name}-stage.azurewebsites.net'
  location: 'East US'
  properties: {
    siteName: 'eshop-demo-alex(stage)'
    hostNameType: 'Verified'
  }
  dependsOn: [

    website-name_resource
  ]
}