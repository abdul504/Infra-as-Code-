// Params
@description('The id of the APIM instance to which this API will be deployed')
@minLength(1)
param apimName string

// Variables
var groups = loadJsonContent('../Src/APIM/groups/settings.json')

// Resources
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource apimGroups 'Microsoft.ApiManagement/service/groups@2023-03-01-preview' = [for group in groups: {
  name: group.name
  parent: apim
  properties: group.properties
}]
