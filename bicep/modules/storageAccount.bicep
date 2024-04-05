param location string
param storageAccountName string
param storageShareName string = 'foundryvttdata'

@allowed([
  'Premium_50GB'
  'Standard_50GB'
])
param storageConfiguration string = 'Premium_50GB'

var storageConfigurationMap = {
  Premium_50GB: {
    kind: 'FileStorage'
    sku: 'Premium_LRS'
    shareQuota: 50
    largeFileSharesState: null
  }
  Standard_50GB: {
    kind: 'StorageV2'
    sku: 'Standard_LRS'
    shareQuota: 50
    largeFileSharesState: null
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: storageConfigurationMap[storageConfiguration].kind
  sku: {
    name: storageConfigurationMap[storageConfiguration].sku
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: true
    largeFileSharesState: storageConfigurationMap[storageConfiguration].largeFileSharesState
  }

  resource symbolicname 'fileServices@2021-02-01' = {
    name: 'default'

    resource symbolicname 'shares@2021-02-01' = {
      name: storageShareName
      properties: {
        enabledProtocols: 'SMB'
        shareQuota: storageConfigurationMap[storageConfiguration].shareQuota
      }
    }
  }
}
