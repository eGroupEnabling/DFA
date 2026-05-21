using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Newtonsoft.Json;

/// <summary>
/// Sample API Ingestion Function
/// 
/// Purpose: Call an external REST API and store the response in Azure Data Lake Storage
/// 
/// Configuration:
/// - Set environment variable EXTERNAL_API_BASE_URL to your API endpoint
/// - Ensure managed identity has Storage Blob Data Contributor role on Data Lake storage
/// - Optionally store API credentials in Azure Key Vault (reference via Azure.Identity.DefaultAzureCredential)
/// 
/// Deployment:
/// Via Azure DevOps pipeline or VS Code: func azure functionapp publish <FunctionAppName>
/// 
/// Example trigger:
/// HTTP POST to https://<FunctionAppName>.azurewebsites.net/api/IngestApiData
/// Body: {"apiEndpoint": "/users/list", "containerName": "raw", "blobName": "users-data.json"}
/// </summary>

public static class IngestApiData
{
    private static readonly HttpClient client = new HttpClient();
    
    [FunctionName("IngestApiData")]
    public static async Task Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequestMessage req,
        ILogger log)
    {
        log.LogInformation("API Ingestion Function triggered.");

        try
        {
            // Parse request body
            string requestBody = await req.Content.ReadAsStringAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            string apiEndpoint = data?.apiEndpoint;
            string containerName = data?.containerName ?? "raw";
            string blobName = data?.blobName ?? "api-data.json";

            if (string.IsNullOrEmpty(apiEndpoint))
            {
                return;
            }

            // Get configuration from environment
            string apiBaseUrl = Environment.GetEnvironmentVariable("EXTERNAL_API_BASE_URL");
            string storageAccountName = Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_NAME");
            string dataLakeUri = $"https://{storageAccountName}.dfs.core.windows.net";

            log.LogInformation($"Calling API endpoint: {apiBaseUrl}{apiEndpoint}");

            // Call external API using managed identity
            // Note: For API key auth, store key in Key Vault and retrieve via DefaultAzureCredential
            string fullUrl = apiBaseUrl + apiEndpoint;
            
            HttpResponseMessage apiResponse = await client.GetAsync(fullUrl);

            if (!apiResponse.IsSuccessStatusCode)
            {
                log.LogError($"API call failed with status {apiResponse.StatusCode}");
                return;
            }

            string apiContent = await apiResponse.Content.ReadAsStringAsync();
            log.LogInformation($"API response received: {apiContent.Length} bytes");

            // Store response in Data Lake
            await StoreInDataLake(
                dataLakeUri,
                containerName,
                blobName,
                apiContent,
                log);

            log.LogInformation("Data successfully ingested into Data Lake.");
        }
        catch (Exception ex)
        {
            log.LogError($"Error in API ingestion: {ex.Message}");
            log.LogError($"Stack trace: {ex.StackTrace}");
        }
    }

    private static async Task StoreInDataLake(
        string dataLakeUri,
        string containerName,
        string blobName,
        string content,
        ILogger log)
    {
        try
        {
            // Use managed identity for authentication
            var blobServiceClient = new BlobServiceClient(new Uri(dataLakeUri), new Azure.Identity.DefaultAzureCredential());
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            // Convert string to stream
            using (var memoryStream = new MemoryStream(Encoding.UTF8.GetBytes(content)))
            {
                await blobClient.UploadAsync(memoryStream, overwrite: true);
            }

            log.LogInformation($"Blob uploaded: {containerName}/{blobName}");
        }
        catch (Exception ex)
        {
            log.LogError($"Error storing in Data Lake: {ex.Message}");
            throw;
        }
    }
}
