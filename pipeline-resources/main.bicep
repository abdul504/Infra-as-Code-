// Target scope
targetScope = 'subscription'

// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('Location for all resources.')
@minLength(1)
@allowed([
  'westus'
  'westus2'
  'eastus'
  'eastus2'
  'centralus'
])
param location string = 'centralus'

@description('The name of the resource group')
@minLength(1)
param resourceGroupName string

@description('The name of the storage container for open api specs')
@minLength(1)
param openApiContainerName string = 'openapi-specs'

@description('The name of the storage container for coverage results')
@minLength(1)
param coverageContainerName string = 'coverage-results'

// Variables
var environment = 'pl' // This is the pipeline, which will be used across all envs
var shortenedLocation = (location == 'centralus') ? 'cent' : location
var resourceSuffix = '${environment}-${shortenedLocation}'

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module storageAccount 'modules/storage-account.bicep' = {
  name: 'StorageAccount-Deployment'
  scope: resourceGroup
  params: {
    applicationName: applicationName
    location: location
    resourceSuffix: resourceSuffix
  }
}

module blobContainerOpenApi 'modules/blob-container.bicep' = {
  name: 'BlobContainer-OpenApi-Deployment'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    containerName: openApiContainerName
  }
}

module blobContainerCoverageResults 'modules/blob-container.bicep' = {
  name: 'BlobContainer-Coverage-Deployment'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    containerName: coverageContainerName
  }
}

output storageAccountName string = storageAccount.outputs.storageAccountName
output storageAccountUrl string = storageAccount.outputs.storageAccountUrl
output pipelineOpenApiBlobContainerName string = blobContainerOpenApi.outputs.containerName
output pipelineCoverageBlobContainerName string = blobContainerCoverageResults.outputs.containerName
output resourceGroupName string = resourceGroup.name
