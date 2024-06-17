// Params
@description('The name of the APIM instance to which the named values will be deployed')
@minLength(1)
param apimName string

@description('A collection of named value secret references')
param namedValueSecrets array

// Resources
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource namedValues 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = [for secret in namedValueSecrets: {
  parent: apim
  name: secret.displayName
  properties: {
    tags: []
    displayName: secret.displayName
    keyVault: {
      secretIdentifier: secret.secretUri
    }
    secret: true
  }
}]
