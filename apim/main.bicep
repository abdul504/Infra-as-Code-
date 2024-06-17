  // Target scope
targetScope = 'subscription'

// Params
@description('The APIM instance name')
@minLength(1)
param apimName string

@description('The environment to refer to for the API Management service.')
@minLength(2)
@maxLength(2)
@allowed([
  'dv'
  'ts'
  'st'
  'pr'
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

// Variables
var shortenedLocation = (location == 'centralus') ? 'cent' : location
var resourceSuffix = '${environment}-${shortenedLocation}'

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: resourceGroupName
}

module apim 'modules/apim.bicep' = {
  name: 'APIM-Deployment'
  scope: resourceGroup
  params: {
    applicationName: apimName
    resourceSuffix: resourceSuffix
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output apimId string = apim.outputs.apimId
output apimName string = apim.outputs.apimName
output apimProxyHostName string = apim.outputs.apimProxyHostName
output apimPortalHostName string = apim.outputs.apimDeveloperPortalHostName
