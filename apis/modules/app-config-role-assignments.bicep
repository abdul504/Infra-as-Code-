// Params
@description('The name of the App Config')
@minLength(5)
@maxLength(50)
param appConfigName string

@description('A collection of user principal ids to which the role will be granted')
param userPrincipalIds array

// Variables
var dataReaderUserRoleId = '000000000000000000000000000000'

// Resources
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appConfigName
}

resource secretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in userPrincipalIds: {
  name: guid(appConfig.id, principalId)
  scope: appConfig
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', dataReaderUserRoleId)
  }
}]
