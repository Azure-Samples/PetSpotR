@description('Azure region to deploy resources into. Defaults to location of target resource group')
param location string = resourceGroup().location

@description('Name of the Application Insights resource.')
param applicationInsightName string = 'petspotr${uniqueString(resourceGroup().id)}'

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output aiId string = ai.id
