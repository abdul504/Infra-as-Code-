// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

// Variables
var apimName = 'apim-${applicationName}-${resourceSuffix}'

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource apimGlobalPolicy 'Microsoft.ApiManagement/service/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: apim
  dependsOn: [
    apimPolicyFragments
  ]
  properties: {
    format: 'rawxml'
    value: loadTextContent('../../../../Src/APIM/policy.xml')
  }
}

module apimPolicyFragments 'apim-policies.bicep' = {
  name: 'APIM-Policy-Fragments'
  params: {
    apimName: apim.name
  }
}

module apimApis 'apim-apis.bicep' = {
  name: 'APIM-APIs'
  params: {
    apimName: apim.name   
  }
}

module apimGroups 'apim-groups.bicep' = {
  name: 'APIM-Groups'
  params: {
    apimName: apim.name
  }
}

module apimProducts 'apim-products.bicep' = {
  name: 'APIM-Products'
  params: {
    apimName: apim.name    
  }
  dependsOn: [
    apimApis
    apimGroups
  ]
}

// Outputs
output apimId string = apim.id
output apimName string = apim.name
output apimInternalIPAddress string = apim.properties.publicIPAddresses[0]
output apimProxyHostName string = apim.properties.hostnameConfigurations[0].hostName
output apimDeveloperPortalHostName string = replace(apim.properties.developerPortalUrl, 'https://', '')
output apimIdentityPrincipalId string = apim.identity.principalId
