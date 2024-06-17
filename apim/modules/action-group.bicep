// parameters
@description('The email address to send alerts to')
@minLength(1)
param availabilityNotificationsEmail string

@description('The resource suffix of the org in Azure')
@minLength(1)
param resourceSuffix string

// variables
var actionGroupName = 'ag-${resourceSuffix}'

resource onCallActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    enabled: true
    groupShortName: resourceSuffix
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: availabilityNotificationsEmail
        useCommonAlertSchema: true
      }
    ] 
  }
}

output id string = onCallActionGroup.id
