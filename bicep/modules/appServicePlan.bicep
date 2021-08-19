param location string
param appServicePlanName string

@allowed([
  'B1'
  'P1V2'
  'P2V2'
  'P3V2'
  'P1V3'
  'P2V3'
  'P3V3'
])
param appServicePlanConfiguration string = 'B1'

var appServicePlanSkuConfigurationMap = {
  B1: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
  }
  P1V2: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'Pv2'
  }
  P2V2: {
    name: 'P2v2'
    tier: 'PremiumV2'
    size: 'P2v2'
    family: 'Pv2'
  }
  P3V2: {
    name: 'P3v2'
    tier: 'PremiumV2'
    size: 'P3v2'
    family: 'Pv2'
  }
  P1V3: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    family: 'Pv3'
  }
  P2V3: {
    name: 'P2v3'
    tier: 'PremiumV3'
    size: 'P2v3'
    family: 'Pv3'
  }
  P3V3: {
    name: 'P3v3'
    tier: 'PremiumV3'
    size: 'P3v3'
    family: 'Pv3'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: appServicePlanSkuConfigurationMap[appServicePlanConfiguration].name
    tier: appServicePlanSkuConfigurationMap[appServicePlanConfiguration].tier
    size: appServicePlanSkuConfigurationMap[appServicePlanConfiguration].size
    family: appServicePlanSkuConfigurationMap[appServicePlanConfiguration].family
    capacity: 1
  }
  properties: {
    isXenon: false
    hyperV: false
  }
}

output appServicePlanId string = appServicePlan.id
