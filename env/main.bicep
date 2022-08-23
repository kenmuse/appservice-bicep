@description('Web app name.')
@minLength(2)
param webAppName string = uniqueString(resourceGroup().id)

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string = 'B1' // The SKU of App Service Plan

@description('Resource group location')
param location string = resourceGroup().location // Location for all resources

@description('Deploy to Linux or Windows)
param isLinuxDeploy boolean = false

var appServicePlanName = toLower('${webAppName}-plan')
var webSiteName = toLower('${webAppName}-web')
var linuxSiteConfig = isLinuxDeploy ? { 
    linuxFxVersion: 'DOTNETCORE|6.0'
} : { }

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: isLinuxDeploy
  }
  sku: {
    name: sku
  }
  kind:  isLinuxDeploy ? 'linux' : null
}

resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: webSiteName
  location: location
  kind: app
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id,
    httpsOnly: true
    siteConfig: union(linuxSiteConfig, {
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'Disabled'
    })
  }
}
