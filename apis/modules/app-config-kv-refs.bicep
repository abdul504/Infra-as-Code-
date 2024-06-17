// params

@description('The name of the App Configuration instance')
@minLength(1)
param appConfigurationName string

@description('An array of key vault secret names and IDs')
param keyVaultSecrets array

// resources
resource appConfigConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [for secret in keyVaultSecrets: {
  name: '${appConfigurationName}/${secret.key}'
  properties: {
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
    value: '{"uri":"${secret.secretUri}"}'
  }
}]
