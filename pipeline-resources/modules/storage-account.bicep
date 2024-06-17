// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('The location of the resource group')
@minLength(1)
param location string = resourceGroup().location

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

// Variables
var storageAccountName = replace('st${applicationName}${resourceSuffix}', '-', '')

// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Outputs
output storageAccountName string = storageAccount.name
#disable-next-line no-hardcoded-env-urls
output storageAccountUrl string = 'https://${storageAccount.name}.blob.core.windows.net'
