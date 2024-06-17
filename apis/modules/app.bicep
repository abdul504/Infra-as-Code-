// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

@description('The location of the App Service Plan')
@minLength(1)
@allowed([
  'westus'
  'westus2'
  'eastus'
  'eastus2'
  'centralus'
])
param location string

@description('The id of the app service plan in Azure')
@minLength(1)
param appServicePlanId string

@description('The app configuration endpoint')
@minLength(1)
param appConfigurationEndpoint string

@description('The name of the app key vault')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('The name of the app config')
@minLength(5)
@maxLength(50)
param appConfigName string

// Resources
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-${applicationName}-${resourceSuffix}'
  location: location
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      alwaysOn: false
      appSettings: [
        {
          name: 'AppConfig:Endpoint'
          value: appConfigurationEndpoint
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}
  
module keyVaultRoleAssignments 'key-vault-role-assignments.bicep' = {
  name: 'KeyVault-${applicationName}-RoleAssignments'
  params: {
    keyVaultName: keyVaultName
    userPrincipalIds: [
      appService.identity.principalId
    ]
  }
}

module appConfigRoleAssignments 'app-config-role-assignments.bicep' = {
  name: 'AppConfig-${applicationName}-RoleAssignments'
  params: {
    appConfigName: appConfigName
    userPrincipalIds: [
      appService.identity.principalId
    ]
  }
}

// Outputs
output apiUrl string = 'https://${appService.properties.defaultHostName}'
output appServiceName string = appService.name
output appServicePrincipalId string = appService.identity.principalId
