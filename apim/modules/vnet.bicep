// Params
@description('The name of the application')
@minLength(1)
param applicationName string

@description('Location for all resources.')
@minLength(1)
param location string = resourceGroup().location

@description('The prefix for the virtual network address')
@minLength(1)
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The prefix for the subnet address')
@minLength(1)
param subnetAddressPrefix string = '10.0.0.0/24'

// Variables
var nsgName = 'nsg-${applicationName}-${location}'
var vnetName = 'vnet-${applicationName}-${location}'
var subnetApimName = 'snet-${applicationName}-apim-${location}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
     {
        name: 'Client_communication_to_APIM'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Secure_Client_communication_to_APIM'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Management_endpoint_for_Azure_portal_and_Powershell'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'APIM service dependency on Azure Blob and Azure Table Storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Active_Directory_and_Azure_KeyVault_dependency'
        properties: {
          description: 'Connect to Azure Active Directory'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_to_Azure_SQL_endpoints'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_to_Azure_KeyVault'
        properties: {
          description: 'Allow APIM service control  access to KeyVault'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy_and_monitoring_agent'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '5671'
            '5672'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 180
          direction: 'Outbound'
        }
      }
      {
        name: 'Health_and_Monitoring_Extension'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '443'
            '12000'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
        }
      }
      {
        name: 'Publish_Diagnostic_Logs_and_Metrics_Resource_Health_and_Application_Insights'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '1886'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_for_sending_e-mails'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 210
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_Redis_Service_for_Cache_policies_between_machines'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 220
          direction: 'Inbound'
        }
      }
      {
        name: 'Sync_Counters_for_Rate_Limit_policies_between_machines'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 230
          direction: 'Inbound'
        }
      }
      {
        name: 'Azure_Infrastructure_Load_Balancer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 240
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
        subnets: [
      {
        name: subnetApimName
        properties: {
          addressPrefix: subnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.Sql'
            }
            {
              service: 'Microsoft.EventHub'
            }
            {
              service: 'Microsoft.ServiceBus'
            }
          ]
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output vnetName string = vnetName
output apiManagementSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetApimName)
