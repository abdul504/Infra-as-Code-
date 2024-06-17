@description('The name of the application')
@minLength(1)
param name string

@description('The location of the App Service Plan')
@minLength(1)
param location string = resourceGroup().location

@description('The SKU of the App Service Plan')
@minLength(1)
@allowed([
  'F1'
  'B1'
  'S1'
])
param sku string

// Resources
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
  }
}

// Outputs
output id string = appServicePlan.id
