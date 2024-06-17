// Target scope
targetScope = 'subscription'

// Params
@description('The initials of the resource owner')
@minLength(1)
param ownerInitials string 

@description('The name of the application')
@minLength(1)
param applicationName string

@description('The instance size of this API Management service.')
@minLength(1)
@allowed([
  'ld'
])
param environment string

@description('Location for all resources.')
@minLength(1)
@allowed([
  'westus'
  'westus2'
  'eastus'
  'eastus2'
  'centralus'
])
param location string

@description('The name of the resource group')
@minLength(1)
param resourceGroupName string

@description('The collection of api names')
@minLength(1)
param apiNames array

@description('The db connection string for PoWCentral')
@minLength(1)
@secure()
param powCentral string

@description('The cache connection string for APIs')
@minLength(1)
@secure()
param cacheConnectionString string

@description('The username for PoW databases')
@minLength(1)
param powUserId string

@description('The password for PoW databases')
@minLength(1)
@secure()
param powPassword string

// Variables
var shortenedLocation = (location == 'centralus') ? 'cent' : location
var resourceSuffix = '${environment}-${shortenedLocation}'
#disable-next-line no-hardcoded-env-urls
var azureKvUrl = 'vault.azure.net'

var environmentSettings = {
  ld: {
    apiSku: 'F1'
    kvSku: 'standard'
  }
}
var env = environmentSettings[environment]

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    environment: environment
  }
}

module appConfiguration 'modules/app-configuration.bicep' = {
  name: 'APIs-${ownerInitials}-LD-AppConfiguration'
  scope: resourceGroup
  params: {
    applicationName: applicationName
    location: location
    resourceSuffix: resourceSuffix
  }
}
  
module keyVault 'modules/key-vault.bicep' = {
  name: 'APIs-${ownerInitials}-LD-KeyVault'
  scope: resourceGroup
  params: {
    applicationName: applicationName
    location: location
    resourceSuffix: 'ce'
    skuName: env.kvSku
  }
}
  
module keyVaultSecrets '../apim/modules/key-vault-secrets.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'APIS-${ownerInitials}-LD-KeyVault-Secrets'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.name
    secrets: [
      { key: 'ConnectionStrings--PoWCentral', value: powCentral }
      { key: 'CacheConfiguration--CacheConnectionString', value: cacheConnectionString }
      { key: 'ewDbOptions--UserId', value: powUserId }
      { key: 'ewDbOptions--Password', value: powPassword }
    ]
  }
}

module appConfigKvRefs 'modules/app-config-kv-refs.bicep' = {
  dependsOn: [
    appConfiguration
    keyVaultSecrets
  ]
  name: 'APIS-${ownerInitials}-LD-AppConfig-KV-Refs'
  scope: resourceGroup
  params: {
    appConfigurationName: appConfiguration.outputs.name
    keyVaultSecrets: [
      { key: 'ConnectionStrings:PoWCentral', secretUri: 'https://${keyVault.outputs.name}.${azureKvUrl}/secrets/ConnectionStrings--PoWCentral' }
      { key: 'CacheConfiguration:CacheConnectionString', secretUri: 'https://${keyVault.outputs.name}.${azureKvUrl}/secrets/CacheConfiguration--CacheConnectionString' }
      { key: 'ewDbOptions:UserId', secretUri: 'https://${keyVault.outputs.name}.${azureKvUrl}/secrets/ewDbOptions--UserId' }
      { key: 'ewDbOptions:Password', secretUri: 'https://${keyVault.outputs.name}.${azureKvUrl}/secrets/ewDbOptions--Password' }
    ]
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'AppServicePlan-Deployment'
  scope: resourceGroup
  params: {
    name: 'asp-${applicationName}-${resourceSuffix}'
    location: location
    sku: env.apiSku
  }
}

module apis 'modules/app.bicep' = [for apiName in apiNames: {
  name: 'APIs-${apiName}-Deployment'
  scope: resourceGroup
  params: {
    applicationName: '${applicationName}-${apiName}'
    resourceSuffix: resourceSuffix
    location: location
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    appConfigurationEndpoint: appConfiguration.outputs.endpoint
    appConfigName: appConfiguration.outputs.name
  }
}]

// Outputs
output apiDetails array = [for index in range(0, length(apiNames)): {
  name: apiNames[index]
  url: apis[index].outputs.apiUrl
  appService: apis[index].outputs.appServiceName
}]
