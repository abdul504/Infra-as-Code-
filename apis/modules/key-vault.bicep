// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('The location of the Key Vault')
@allowed([
  'westus'
  'westus2'
  'eastus'
  'eastus2'
  'centralus'
])
param location string

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

@description('The SKU of the Key Vault.')
@minLength(1)
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

// Variables
var keyVaultName = 'kv${applicationName}api${resourceSuffix}'

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForTemplateDeployment: false
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
  }
}

output name string = keyVault.name
