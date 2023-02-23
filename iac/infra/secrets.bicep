@description('The kube config for the target Kubernetes cluster.')
@secure()
param kubeConfig string

@description('Azure Storage Account name')
param storageAccountName string

@description('Azure Storage Account key')
@secure()
param storageAccountKey string

@description('Azure CosmosDB URL')
param cosmosUrl string

@description('Azure CosmosDB account key')
@secure()
param cosmosAccountKey string

@description('Service Bus Authorization Rule connection string')
@secure()
param serviceBusConnectionString string

import 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

resource serviceBusSecret 'core/Secret@v1' = {
  metadata: {
    name: 'servicebus'
  }
  stringData: {
    connectionString: serviceBusConnectionString
  }
}

resource storageSecret 'core/Secret@v1' = {
  metadata: {
    name: 'storage'
  }
  stringData: {
    accountName: storageAccountName
    accountKey: storageAccountKey
  }
}

resource cosmosSecret 'core/Secret@v1' = {
  metadata: {
    name: 'cosmos'
  }
  stringData: {
    url: cosmosUrl
    masterKey: cosmosAccountKey
  }
}
