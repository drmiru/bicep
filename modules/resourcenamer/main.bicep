//=============================================================================
// Naming Conventions for Azure Resources
//=============================================================================

// Get resource name based on the naming convention taken from the Cloud Adoption Framework.
// Convention: <resourceType>-<workload>-<environment>-<region>-<instance>
// Source: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming



@export()
func getResourceName(resourceType string, workload string, environment string, region string, instance string) string =>
  enforceNamingRules(
    resourceType,
    (requiresGlobalUniqueness(resourceType) && shouldBeShortened(resourceType))
      ? getShortenedResourceName(resourceType, workload, environment, region, getStaticRandom(workload, environment, region))
      : (requiresGlobalUniqueness(resourceType)
          ? getResourceNameByConvention(resourceType, workload, environment, region, getStaticRandom(workload, environment, region))
          : (shouldBeShortened(resourceType)
              ? getShortenedResourceName(resourceType, workload, environment, region, instance)
              : getResourceNameByConvention(resourceType, workload, environment, region, instance)))
  )

// Enforce naming rules (allowed chars, length) per resource type
func enforceNamingRules(resourceType string, name string) string =>
  resourceType == 'storageAccount'
    ? enforceStorageAccountRules(name)
    : resourceType == 'keyVault'
      ? enforceKeyVaultRules(name)
      : resourceType == 'containerRegistry'
        ? enforceContainerRegistryRules(name)
        : resourceType == 'publicIpAddress'
          ? enforcePublicIpRules(name)
          : name

// Storage Account: 3-24 chars, lowercase letters and numbers only

func enforceStorageAccountRules(name string) string =>
  substring(replace(replace(name, '[^a-z0-9]', ''), '-', ''), 0, min(length(replace(replace(name, '[^a-z0-9]', ''), '-', '')), 24))

// Key Vault: 3-24 chars, alphanum and hyphens, start/end with alphanum, no consecutive hyphens
func enforceKeyVaultRules(name string) string =>
  enforceKeyVaultStartEnd(trimConsecutiveHyphens(substring(replace(name, '[^a-z0-9-]', ''), 0, min(length(replace(name, '[^a-z0-9-]', '')), 24))))
func trimConsecutiveHyphens(name string) string => replace(name, '--', '-')
func enforceKeyVaultStartEnd(name string) string =>
  removeTrailingHyphen(removeLeadingHyphen(name))

// Remove leading hyphen if present
func removeLeadingHyphen(name string) string =>
  (startsWith(name, '-') && length(name) > 1) ? substring(name, 1, length(name)) : name

// Container Registry: 5-50 chars, lowercase letters and numbers only
func enforceContainerRegistryRules(name string) string =>
  substring(replace(replace(name, '[^a-z0-9]', ''), '-', ''), 0, min(length(replace(replace(name, '[^a-z0-9]', ''), '-', '')), 50))

// Public IP: 1-80 chars, alphanum, underscores, periods, hyphens, and parenthesis
func enforcePublicIpRules(name string) string =>
  substring(replace(name, '[^a-zA-Z0-9_.()\\-]', ''), 0, 80)

// Returns a static random string for uniqueness (5 chars)
func getStaticRandom(workload string, environment string, region string) string => substring(uniqueString(workload, environment, region), 0, 5)

// List of resource types that require global uniqueness
func requiresGlobalUniqueness(resourceType string) bool => contains(getGloballyUniqueResourceTypes(), resourceType)

func getGloballyUniqueResourceTypes() array => [
  'storageAccount'
  'keyVault'
  'containerRegistry'
  'cosmosDb'
  'signalrService'
  'frontDoor'
  'cdnProfile'
  'cdnEndpoint'
  'eventHubNamespace'
  'serviceBusNamespace'
  'redisCache'
  'searchService'
  'recoveryServicesVault'
  'logAnalyticsWorkspace'
  'appService'
  'webApp'
  'functionApp'
  'automationAccount'
  'batchAccount'
  'notificationHubNamespace'
  'mariadbServer'
  'mysqlServer'
  'postgresqlServer'
  'sqlDatabaseServer'
  'synapseWorkspace'
]

func getResourceNameByConvention(resourceType string, workload string, environment string, region string, instance string) string => 
  sanitizeResourceName('${getPrefix(resourceType)}-${workload}-${abbreviateEnvironment(environment)}-${abbreviateRegion(region)}-${instance}')


//=============================================================================
// Shorten Names
//=============================================================================

func shouldBeShortened(resourceType string) bool => contains(getResourcesTypesToShorten(), resourceType)

// This is a list of resources that should be shortened.
func getResourcesTypesToShorten() array => [
  'keyVault'        // Has max length of 24
  'storageAccount'  // Has max length of 24 and only allows letters and numbers
  'virtualMachine'  // Has max length of 15 for Windows
]

func getShortenedResourceName(resourceType string, workload string, environment string, region string, instance string) string =>
  resourceType == 'virtualMachine'
    ? getVirtualMachineName(workload, environment, region, instance)
    : shortenString(getResourceNameByConvention(resourceType, workload, environment, region, instance))

// Virtual machines have a max length of 15 characters so we use uniqueString to generate a short unique name
func getVirtualMachineName(workload string, environment string, region string, instance string) string =>
  'vm${substring(uniqueString(workload, environment, region), 0, 13-length(shortenString(instance)))}${shortenString(instance)}'

// Shorten the string by removing hyphens and sanitizing the resource name.
func shortenString(value string) string => removeHyphens(sanitizeResourceName(value))
func removeHyphens(value string) string => replace(value, '-', '')


//=============================================================================
// Sanitize
//=============================================================================

// Sanitize the resource name by removing illegal characters and converting it to lower case.
func sanitizeResourceName(value string) string => toLower(removeTrailingHyphen(removeColons(removeCommas(removeDots(removeSemicolons(removeUnderscores(removeWhiteSpaces(value))))))))

func removeTrailingHyphen(value string) string => endsWith(value, '-') ? substring(value, 0, max(0, length(value)-1)) : value
func removeColons(value string) string => replace(value, ':', '')
func removeCommas(value string) string => replace(value, ',', '')
func removeDots(value string) string => replace(value, '.', '')
func removeSemicolons(value string) string => replace(value, ';', '')
func removeUnderscores(value string) string => replace(value, '_', '')
func removeWhiteSpaces(value string) string => replace(value, ' ', '')


//=============================================================================
// Prefixes
//=============================================================================

func getPrefix(resourceType string) string => getPrefixMap()[resourceType]

// Prefixes for commonly used resources.
// Source for abbreviations: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
func getPrefixMap() object => {
  actionGroup: 'ag'
  alert: 'al'
  apiManagement: 'apim'
  applicationGateway: 'agw'
  applicationInsights: 'appi'
  appService: 'app'
  appServiceCertificate: 'asc'
  appServiceEnvironment: 'ase'
  appServicePlan: 'asp'
  automationAccount: 'aa'
  automationRunbook: 'rb'
  automationSchedule: 'as'
  automationVariable: 'av'
  availabilitySet: 'as'
  batchAccount: 'ba'
  batchPool: 'bp'
  cacheForRedis: 'cr'
  cdnEndpoint: 'cde'
  cdnProfile: 'cdp'
  cognitiveServices: 'cog'
  containerGroup: 'cg'
  containerInstance: 'ci'
  containerRegistry: 'acr'
  cosmosDb: 'cosmos'
  dataFactory: 'df'
  dataLakeAnalytics: 'dla'
  dataLakeStore: 'dls'
  disk: 'disk'
  dnsZone: 'dns'
  eventGridDomain: 'egd'
  eventGridTopic: 'egt'
  eventHub: 'eh'
  eventHubNamespace: 'ehn'
  expressRouteCircuit: 'erc'
  firewall: 'fw'
  frontDoor: 'afd'
  functionApp: 'func'
  image: 'img'
  iotHub: 'iot'
  keyVault: 'kv'
  kubernetesService: 'aks'
  loadBalancerInternal: 'lbi'
  loadBalancerExternal: 'lbe'
  loadBalancerRule: 'rule'
  logicApp: 'logic'
  logAnalyticsWorkspace: 'log'
  logAnalyticsQueryPack: 'pack'
  managedIdentity: 'id'
  managedDisk: 'md'
  mariadbServer: 'mariadb'
  mysqlServer: 'mysql'
  networkInterface: 'nic'
  networkSecurityGroup: 'nsg'
  networkWatcher: 'nw'
  notificationHub: 'nh'
  notificationHubNamespace: 'nhn'
  postgresqlServer: 'psql'
  privateDnsZone: 'pdns'
  privateEndpoint: 'pep'
  privateLinkService: 'pls'
  publicIpAddress: 'pip'
  recoveryServicesVault: 'rsv'
  redisCache: 'rc'
  resourceGroup: 'rg'
  routeTable: 'rt'
  searchService: 'ss'
  serviceBusNamespace: 'sbns'
  serviceBusQueue: 'sbq'
  serviceBusTopic: 'sbt'
  serviceBusTopicSubscription: 'sbts'
  signalrService: 'sig'
  sqlDatabase: 'sqldb'
  sqlDatabaseServer: 'sql'
  staticWebapp: 'stapp'
  storageAccount: 'st'
  storageContainer: 'sc'
  storageQueue: 'sq'
  storageTable: 'stb'
  subnet: 'snet'
  synapseWorkspace: 'syn'
  trafficManagerProfile: 'tmp'
  userAssignedIdentity: 'uai'
  virtualMachine: 'vm'
  virtualMachineScaleSet: 'vmss'
  virtualNetwork: 'vnet'
  virtualNetworkGateway: 'vng'
  webApp: 'app'
  
  // Custom prefixes not specified on the Microsoft site
  webtest: 'webtest'
}


//=============================================================================
// Environments
//=============================================================================

func abbreviateEnvironment(environment string) string => getEnvironmentMap()[toLower(environment)]

// By using a map for the environments, we can keep the names short but also only allow a specific set of values.
func getEnvironmentMap() object => {
  dev: 'dev'
  development: 'dev'
  tst: 'tst'
  test: 'tst'
  acc: 'acc'
  acceptance: 'acc'
  prd: 'prd'
  prod: 'prd'
  production: 'prd'
}

//=============================================================================
// Regions
//=============================================================================

func abbreviateRegion(region string) string => getRegionMap()[region]

// Map Azure region name to Short Name (CAF) abbrevation taken from: https://www.jlaundry.nz/2022/azure_region_abbreviations/
func getRegionMap() object => {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  brazilsoutheast: 'bse'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralindia: 'inc'
  centralus: 'cus'
  centraluseuap: 'ccy'
  eastasia: 'ea'
  eastus: 'eus'
  eastus2: 'eus2'
  eastus2euap: 'ecy'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  italynorth: 'itn'
  japaneast: 'jpe'
  japanwest: 'jpw'
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  qatarcentral: 'qac'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  southindia: 'ins'
  southeastasia: 'sea'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westindia: 'inw'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinanorth3: 'bjb3'
  germanycentral: 'gec'
  germanynortheast: 'gne'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  usnateast: 'exe'
  usnatwest: 'exw'
  usseceast: 'rxe'
  ussecwest: 'rxw'
}
