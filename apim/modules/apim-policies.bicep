// Params
@description('The id of the APIM instance to which this API will be deployed')
@minLength(1)
param apimName string

// Resources
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource deleteDefaultResponseHeadersPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-03-01-preview' = {
  name: 'delete-default-response-headers'
  parent: apim
  properties: {
    description: 'Deletes the default APIM .NET response headers'
    format: 'rawxml'
    value: loadTextContent('../../../../Src/APIM/policy-fragments/delete-default-response-headers.xml')
  }
}

resource setInboundCorrelationIdPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-03-01-preview' = {
  name: 'set-inbound-correlation-id-header'
  parent: apim
  properties: {
    description: 'Sets a correlation id header on the request if does not exist'
    format: 'rawxml'
    value: loadTextContent('../../../../Src/APIM/policy-fragments/inbound-set-correlation-id-header.xml')
  }
}

resource setOutboundCorrelationIdPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-03-01-preview' = {
  name: 'set-outbound-correlation-id-header'
  parent: apim
  properties: {
    description: 'Sets the correlation id header on the response'
    format: 'rawxml'
    value: loadTextContent('../../../../Src/APIM/policy-fragments/outbound-set-correlation-id-header.xml')
  }
}
