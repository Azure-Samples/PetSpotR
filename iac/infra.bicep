// Infrastructure ----------------------------------------------------

param location string = resourceGroup().location

@description('Which mode to deploy the infrastructure. Defaults to cloud, which deploys everything. The mode dev only deploys the resources needed for local development.')
@allowed([
  'cloud'
  'dev'
])
param mode string = 'cloud'

module storage 'infra/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
  }
}

module registry 'infra/container-registry.bicep' = {
  name: 'registry'
  params: {
    location: location
  }
}

module servicebus 'infra/servicebus.bicep' = if (mode == 'cloud') {
  name: 'servicebus'
  params: {
    location: location
  }
}

module aks 'infra/aks.bicep' = if (mode == 'cloud') {
  name: 'aks'
  params: {
    location: location
  }
}

