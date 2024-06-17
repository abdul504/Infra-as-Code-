
// Params
@description('The name of the Key Vault')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('A collection of user principal ids to which the role will be granted')
param userPrincipalIds array

// Variables
var secretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource secretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in userPrincipalIds: {
  name: guid(keyVault.id, principalId)
  scope: keyVault
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', secretsUserRoleId)
  }
}]
