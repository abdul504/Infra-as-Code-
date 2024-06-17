@description('The host name that should be used when connecting to the origin for the API Management proxy gateway.')
@minLength(1)
param proxyOriginHostName string

@description('The host name that should be used when connecting to the origin for the API Management developer portal.')
@minLength(1)
param developerPortalOriginHostName string

@description('The name of the Front Door endpoint to create for the API Management proxy gateway. This must be globally unique.')
@minLength(1)
param proxyEndpointName string

@description('The name of the Front Door endpoint to create for the API Management developer portal. This must be globally unique.')
@minLength(1)
param developerPortalEndpointName string

@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@minLength(1)
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string

@description('The name of the application to use when creating the Front Door profile.')
@minLength(1)
param applicationName string

@description('The name of the environment to use when creating the Front Door profile.')
@minLength(1)
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

var profileName = 'afd-${applicationName}-${environment}'
var proxyOriginGroupName = 'Proxy'
var developerPortalOriginGroupName = 'DeveloperPortal'
var proxyOriginName = 'ApiManagementProxy'
var developerPortalOriginName = 'ApiManagementDeveloperPortal'
var proxyRouteName = 'ProxyRoute'
var developerPortalRouteName = 'DeveloperPortalRoute'

resource profile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource proxyEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: proxyEndpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource proxyOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: proxyOriginGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource proxyOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: proxyOriginName
  parent: proxyOriginGroup
  properties: {
    hostName: proxyOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: proxyOriginHostName
    priority: 1
    weight: 1000
  }
}

resource proxyRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: proxyRouteName
  parent: proxyEndpoint
  dependsOn: [
    proxyOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: proxyOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

resource developerPortalEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: developerPortalEndpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource developerPortalOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: developerPortalOriginGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource developerPortalOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: developerPortalOriginName
  parent: developerPortalOriginGroup
  properties: {
    hostName: developerPortalOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: developerPortalOriginHostName
    priority: 1
    weight: 1000
  }
}

resource developerPortalRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: developerPortalRouteName
  parent: developerPortalEndpoint
  dependsOn: [
    developerPortalOrigin 
  ]
  properties: {
    originGroup: {
      id: developerPortalOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorId string = profile.properties.frontDoorId
output frontDoorProxyEndpointHostName string = proxyEndpoint.properties.hostName
output frontDoorDeveloperPortalEndpointHostName string = developerPortalEndpoint.properties.hostName
