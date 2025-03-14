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
param sku string = 'B1'

@description('Resource group location')
param location string = resourceGroup().location

@description('Deploy to Linux or Windows')
param isLinuxDeploy bool = false

@description('Tags to be applied to the resources')
param tagsByResource object = {}

var appServicePlanName = toLower('${webAppName}-plan')
var webSiteName = toLower('${webAppName}-web')
var linuxSiteConfig = isLinuxDeploy ? { 
    linuxFxVersion: 'DOTNETCORE|6.0'
} : { }

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: isLinuxDeploy
  }
  sku: {
    name: sku
  }
  kind:  isLinuxDeploy ? 'linux' : ''
  tags: tagsByResource[?'Microsoft.Web/serverfarms'] ?? {}
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  kind: 'app'
  tags: tagsByResource[?'Microsoft.Web/sites'] ?? {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
    siteConfig: union(linuxSiteConfig,{
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      http20Enabled: true
      httpLoggingEnabled: false
      detailedErrorLoggingEnabled: false
      use32BitWorkerProcess: false
      webSocketsEnabled: true
      alwaysOn: true
      ftpsState: 'Disabled'
    })
  }
}

resource appSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: appService
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: '1'
  }
}

output appServiceName string = appService.name
output appServiceHost string = appService.properties.defaultHostName
