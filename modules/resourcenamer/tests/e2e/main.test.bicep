import { getResourceName } from './../../main.bicep'

param location string = resourceGroup().location
param environment string = 'dev'
param workload string = 'mywebapp'

param vnetName string = getResourceName('virtualNetwork', workload, environment, location, '001')

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource kv 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: getResourceName('keyVault', workload, environment, location, '001')
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'}
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    accessPolicies: []
  }
}

resource sto 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: getResourceName('storageAccount', workload, environment, location, '001')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource law 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: getResourceName('logAnalyticsWorkspace', workload, environment, location, '001')
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
