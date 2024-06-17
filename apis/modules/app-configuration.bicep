// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('The location of the App Configuration')
param location string = resourceGroup().location

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

// Variables
var appConfigName = 'appc-${applicationName}-${resourceSuffix}'

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: 'standard'
  }
}

output endpoint string = appConfig.properties.endpoint
output name string = appConfig.name
