## Prerequisites

Before you deploy the Data Foundation Accelerator, confirm the following:

- You have an Azure subscription and permission to deploy resources into the
  target resource group.
- You have enough regional quota for the selected components, especially
  Fabric capacity, SQL Database, storage, API Management, and private
  endpoints if enabled.
- You know whether this deployment should create a new Fabric capacity or use
  an existing capacity or manually activated Fabric trial.
- You have a SQL administrator login and a strong password that satisfies the
  portal validation rules.
- If you plan to enable Defender for Cloud configuration, the deploying
  identity can update Defender pricing plans at the subscription scope.

## Deploy From Azure Marketplace

The recommended path is the marketplace entry point linked from the repository
README.

1. Open the marketplace deployment experience.
2. Select the target subscription, resource group, and region.
3. Choose the Fabric capacity option:
   - `none`: do not deploy a new Fabric capacity
   - `initial`: deploy a new `F2` capacity
   - `production`: deploy a new `F4` capacity by default, with optional SKU
     override during source-based deployment
4. Enter the customer contact details collected for installation tracking.
5. Configure the deployment options:
   - `resourceNamePrefix`: 3-11 lowercase alphanumeric characters
   - `environment`: `dev`, `test`, or `prod`
   - `enablePrivateEndpoints`: private connectivity toggle
   - `defenderSecurityConfiguration`: `foundational`, `standard`, or `none`
   - `enableApiIngestionFunction`: optional Function App deployment
   - `externalApiBaseUrl`: optional HTTPS base URL for the ingestion Function
   - `enableApiManagement`: optional API Management deployment
   - `sqlAdministratorLogin` and `sqlAdministratorPassword`
6. Review the deployment summary and create the resources.

Typical deployment time is 20-45 minutes. Fabric capacity creation can take
longer than the rest of the resource group.

## Deploy From Source

If you need to validate or automate the deployment outside Azure Marketplace,
deploy `src/mainTemplate.json` directly.

```bash
az deployment group create \
  --name dfa-deployment \
  --resource-group <resource-group> \
  --template-file ./src/mainTemplate.json \
  --parameters \
    resourceNamePrefix=contoso \
    deploymentTier=initial \
    environment=prod \
    location=eastus \
    enablePrivateEndpoints=true \
    defenderSecurityConfiguration=none \
    enableApiIngestionFunction=true \
    externalApiBaseUrl= \
    enableApiManagement=false \
    sqlAdministratorLogin=sqladminuser \
    sqlAdministratorPassword='<secure-value>' \
    customerName='Contoso Admin' \
    customerEmail='admin@contoso.com' \
    customerPhone=''
```

Notes:

- `customerName` and `customerEmail` are required because the deployment
  records installation metadata.
- `fabricCapacitySku` is optional and only applies when `deploymentTier` is
  not `none`.
- `fabricCapacityAdministrators` is optional and can be supplied as an array
  during source-based deployments.
- For automation, prefer parameter files or a secure secret store instead of
  inline secrets.

## Post-Deployment Validation

After deployment completes, verify the following:

1. The target resource group contains the expected core resources: virtual
   network, storage account, Key Vault, SQL Server, and SQL Database.
2. The storage account contains the `raw`, `ingestion`, `archive`,
   `function-host`, and `function-data` containers.
3. If you selected `initial` or `production`, the Fabric capacity resource is
   present and reaches an active state.
4. If you selected `none`, confirm that your existing capacity or Fabric trial
   is available separately in the Fabric portal.
5. The SQL Database is online and accepts connections with the configured
   administrator login.
6. If you enabled the API ingestion Function, the Function App is running and
   the expected application settings are present.
7. If you enabled API Management, the instance is provisioned successfully.
8. If you enabled Defender for Cloud configuration, confirm the expected plan
   state in Microsoft Defender for Cloud at the subscription level.

## Current Behavior Notes

- The `none` deployment tier does not provision a Fabric capacity. Fabric
  trial activation happens outside this template.
- Virtual network address ranges are template-defined today: `10.0.0.0/16`
  for the address space, `10.0.1.0/24` for the default subnet, and
  `10.0.2.0/24` for the private endpoints subnet.
- Defender for Cloud changes apply at the subscription scope rather than only
  within the target resource group.
- The deployment captures customer contact details for installation tracking.

## Cleanup

Delete the resource group when you want to remove the deployment:

```bash
az group delete --name <resource-group> --yes
```

If a Key Vault remains soft-deleted after cleanup, remember that purge
protection can delay permanent removal.
