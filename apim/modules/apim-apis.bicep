// Params
@description('The id of the APIM instance to which this API will be deployed')
@minLength(1)
param apimName string

// Variables
var customersV0 = loadJsonContent('../pipeline-resources/settings.json')


// Resources
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

// Version sets
resource customersV0VersionSet 'Microsoft.ApiManagement/service/apiVersionSets@2023-03-01-preview' = {
  name: 'customers-version-set'
  parent: apim
  properties: {
    description: 'customers API version set'
    displayName: 'customers API'
    versioningScheme: 'Segment'
  }
}

// APIs
resource customersV0ApimApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  name: 'customers-api-v0;rev=v6'
  parent: apim
  properties: {
    apiVersionSetId: customersVersionSet.id
    sourceApiId:'v0'
    apiVersion: customersV0.properties.apiVersion
    apiRevision: customersV0.properties.apiRevision
    apiRevisionDescription: customersV0.properties.apiRevisionDescription
    displayName: customersV0.properties.displayName
    description: customersV0.properties.description
    serviceUrl: customersV0.properties.serviceUrl
    isCurrent: customersV0.properties.isCurrent
    path: customersV0.properties.path
    protocols: customersV0.properties.protocols
    apiType: customersV0.properties.apiType
    format: customersV0.properties.format
    value: customersV0.properties.value
    subscriptionKeyParameterNames: {
      header: customersV0.properties.subscriptionKeyParameterNames.header
      query: customersV0.properties.subscriptionKeyParameterNames.query
    }
    subscriptionRequired: customersV0.properties.subscriptionRequired
    authenticationSettings: customersV0.properties.authenticationSettings
  }

 
}



// Outputs
output CustomersUrl string = customersV0ApimApi.properties.serviceUrl

