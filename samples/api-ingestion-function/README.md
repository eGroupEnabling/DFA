This directory contains a sample C# Azure Function that demonstrates how to:
- Call an external REST API
- Store the response in Azure Data Lake Storage Gen2
- Handle errors and logging
- Use managed identity for secure authentication

## Overview

The `IngestApiData` function is an HTTP-triggered Function App that:
1. Receives an HTTP POST request with an API endpoint path, container name, and blob name
2. Calls the external REST API (configured via `EXTERNAL_API_BASE_URL` environment variable)
3. Stores the JSON response in the Data Lake storage account
4. Logs all operations for monitoring and troubleshooting

## Deployment

### Prerequisites
- Azure CLI or Azure DevOps pipeline
- Local Azure Functions Core Tools (optional, for local testing)
- Function App deployed by ARM template

### Deploy via Azure CLI

```bash
# Navigate to this directory
cd samples/api-ingestion-function

# Login to Azure
az login

# Publish function to Function App
func azure functionapp publish <FunctionAppName>
```

### Deploy via Visual Studio Code

1. Install Azure Functions extension
2. Open this folder in VS Code
3. Click "Deploy to Function App" and select your Function App
4. Confirm deployment

### Deploy via Azure DevOps CI/CD

Example pipeline step:

```yaml
- task: AzureFunctionApp@1
  inputs:
    azureSubscription: 'YourServiceConnection'
    appType: 'functionApp'
    appName: '$(FunctionAppName)'
    package: '$(Build.ArtifactStagingDirectory)/drop'
```

## Configuration

### Environment Variables

Set these in Function App settings (Azure Portal or via CLI):

- **EXTERNAL_API_BASE_URL**: Base URL of the external API (e.g., `https://api.example.com`)
- **STORAGE_ACCOUNT_NAME**: Name of Data Lake storage account (auto-set by ARM template)

### API Key / Secrets (Optional)

If your external API requires authentication:

1. Store API key/credentials in Azure Key Vault
2. Update `IngestApiData.cs` to retrieve from Key Vault using `Azure.Identity.DefaultAzureCredential()`
3. Example:

```csharp
var kvUri = new Uri($"https://<KeyVaultName>.vault.azure.net");
var client = new SecretClient(kvUri, new DefaultAzureCredential());
KeyVaultSecret secret = client.GetSecret("ApiKey");
string apiKey = secret.Value;
// Use apiKey in API call headers
```

### Managed Identity

The function uses `Azure.Identity.DefaultAzureCredential()` for authentication to Data Lake. Ensure:

1. Function App has managed identity enabled (default in ARM template)
2. Managed identity has "Storage Blob Data Contributor" role on Data Lake storage account
3. Role assignment can be done via:

```bash
az role assignment create \
  --assignee <FunctionAppManagedIdentityPrincipalId> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Storage/storageAccounts/<saName>
```

## Usage

### HTTP Request Example

```bash
curl -X POST https://<FunctionAppName>.azurewebsites.net/api/IngestApiData \
  -H "Content-Type: application/json" \
  -d '{
    "apiEndpoint": "/users/list",
    "containerName": "raw",
    "blobName": "users-20250204.json"
  }' \
  -H "x-functions-key: <FunctionKey>"
```

### Request Body Format

```json
{
  "apiEndpoint": "/path/to/endpoint",  // Appended to EXTERNAL_API_BASE_URL
  "containerName": "raw",               // Target container in Data Lake (raw/refined/processed/shared)
  "blobName": "filename.json"           // Target blob name
}
```

### Response

- **Success (200)**: Data ingested to Data Lake
- **Error (400)**: Missing required parameters
- **Error (500)**: API call or storage error (check Function App logs)

## Monitoring & Logs

View function logs in Azure Portal:

1. Go to Function App > **IngestApiData** function
2. Click **Monitor** tab
3. View invocation logs and check for errors

Or via Azure CLI:

```bash
az webapp log tail --resource-group <rgName> --name <FunctionAppName>
```

## Scaling & Performance

- **Default**: Consumption plan (pay-per-execution, no guarantees)
- **For higher throughput**: Consider App Service plan or Premium plan
- **Concurrency**: Consumption plan supports up to 200 concurrent invocations

## Troubleshooting

### "Authentication failed" error
- Ensure Function App managed identity has Storage Blob Data Contributor role
- Check Key Vault access policies if storing credentials

### "API call failed" error
- Verify `EXTERNAL_API_BASE_URL` is correct
- Check if external API is accessible from Function App
- Confirm API authentication (headers, tokens, IP allowlisting)

### "Blob upload failed" error
- Verify storage account name in `STORAGE_ACCOUNT_NAME` environment variable
- Confirm container exists in Data Lake (`raw`, `refined`, `processed`, `shared`)
- Check managed identity permissions

## Next Steps

1. **Customize for your API**: Update endpoint parsing, request headers, JSON transformation
2. **Add error handling**: Implement retry logic, dead-letter queue for failed ingestions
3. **Schedule periodic runs**: Use Timer trigger instead of HTTP for scheduled ingestion
4. **Transform data**: Add JSON parsing and schema validation before storing
5. **Monitor costs**: Set up Application Insights to track invocation counts and duration

## References

- [Azure Functions C# developer guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-dotnet-class-library)
- [Azure.Storage.Blobs SDK](https://docs.microsoft.com/en-us/dotnet/api/azure.storage.blobs)
- [Azure.Identity (Managed Identity)](https://docs.microsoft.com/en-us/dotnet/api/azure.identity)
- [Azure Key Vault client library](https://docs.microsoft.com/en-us/dotnet/api/azure.security.keyvault.secrets)
- [Azure DevOps Function App Deployment Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-function-app)
