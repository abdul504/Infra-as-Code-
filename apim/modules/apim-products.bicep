// Params
@description('The id of the APIM instance to which this API will be deployed')
@minLength(1)
param apimName string

// Variables
var customersConnectBasic = loadJsonContent('../../customers-connect/basic/settings.json')
var customersConnectPlus = loadJsonContent('../..//customers-connect/plus/settings.json')

// Resources
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource customersConnectBasicProduct 'Microsoft.ApiManagement/service/products@2023-03-01-preview' = {
  name: customersConnectBasic.name
  parent: apim
  properties: customersConnectBasic.properties

  resource apis 'apis@2023-03-01-preview' = [for api in customersConnectBasic.apis: {
    name: api
  }]

  resource groups 'groups@2023-03-01-preview' = [for group in customersConnectBasic.groups: {
    name: group
  }]
}

resource customersConnectPlusProduct 'Microsoft.ApiManagement/service/products@2023-03-01-preview' = {
  name: customersConnectPlus.name
  parent: apim
  properties: customersConnectPlus.properties

  resource apis 'apis@2023-03-01-preview' = [for api in customersConnectPlus.apis: {
    name: api
  }]
  
  resource groups 'groups@2023-03-01-preview' = [for group in customersConnectPlus.groups: {
    name: group
  }]
}
