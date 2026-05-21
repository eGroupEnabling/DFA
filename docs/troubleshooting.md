## Deployment Failures

### Insufficient quota

If the deployment fails with a quota error, check Azure quota in the selected
region for the services you enabled. Fabric capacity, API Management, private
endpoints, and SQL are the most common blockers.

### Invalid region for Fabric capacity

Fabric capacity is not available in every region. If the region does not
support the selected Fabric SKU, redeploy in a region where Fabric, SQL,
storage, and any optional services are all available.

### Authorization failures

Two permission scopes matter:

- Resource group permissions for the main deployment
- Subscription-scope permissions if Defender for Cloud pricing changes are
  enabled

If the deployment fails on `Microsoft.Security/pricings/write`, redeploy with
`defenderSecurityConfiguration = none` or use an identity that can manage
Defender plans at the subscription scope.

### SQL credential validation

The portal validates SQL administrator names and passwords aggressively. If the
deployment fails validation:

- choose a different administrator login
- use a 12-123 character password with uppercase, lowercase, numeric, and
  special characters
- avoid common weak-password patterns

## Post-Deployment Access Issues

### Cannot connect to SQL Database

Check the following in order:

1. The database is online and the SQL Server deployment succeeded.
2. The login and password match the values used during deployment.
3. If private endpoints are enabled, your client can resolve the private SQL
   endpoint and reach the target network.
4. If private endpoints are disabled, your client IP or Azure services are
   allowed through the SQL networking configuration.

### Cannot access storage containers

If the storage account exists but access fails:

- confirm your identity has a storage data role such as Blob Data Contributor
- check storage networking rules
- if private endpoints are enabled, validate DNS resolution and network pathing

### Key Vault access denied

Key Vault failures are usually one of these:

- missing RBAC or access policy permissions
- private endpoint connectivity problems
- firewall rules that do not allow your access path

### Function App or API Management is unavailable

If an optional service is enabled but unavailable immediately after deployment,
wait for provisioning to complete and then verify its resource-specific status
page. API Management can take longer to become fully reachable than the rest of
the deployment.

## Networking And DNS

When `enablePrivateEndpoints` is turned on, networking errors often come from
DNS rather than from the resource itself.

Validate these items:

- private endpoints exist in the dedicated subnet
- private DNS zones were created and linked correctly
- the client network can route to the virtual network
- name resolution returns private addresses for storage, SQL, and Key Vault

## Naming And Uniqueness Issues

Storage account names must be globally unique. If deployment fails because a
name is taken, choose a different `resourceNamePrefix` and redeploy.

If resource names are too long, shorten the prefix. The template derives
multiple resource names from that value and some Azure resource types have
tighter limits than others.

## Cleanup Issues

Key Vault purge protection can prevent immediate permanent removal after the
resource group is deleted. That behavior is expected. If you need full cleanup,
check whether the vault remains soft-deleted and follow Azure purge guidance.

## Getting Help

Start with the deployment activity log and the failed deployment operation.
Then include the following in your support request:

- deployment tier and Azure region
- resource group name
- exact error text
- whether private endpoints, Defender for Cloud, API ingestion, or API
  Management were enabled

Support contacts are listed in [SUPPORT.md](../SUPPORT.md).
