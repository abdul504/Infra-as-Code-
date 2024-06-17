// Params
@description('The name of the Key Vault instance')
@minLength(1)
param keyVaultName string

@description('Collection of secret key value pairs to be added to the Key Vault')
param secrets array = []

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for secret in secrets: {
  name: secret.key
  parent: keyVault
  properties: {
    value: secret.value
  }
}]
