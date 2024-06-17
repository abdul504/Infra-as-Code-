// Params
@description('The name of the storageAccount')
@minLength(1)
param storageAccountName string

@description('Specifies the name of the blob container.')
@minLength(1)
param containerName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: containerName
  parent: blobService
  properties: {}
}

output containerName string = container.name

