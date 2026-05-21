# Clean up trial sample data before upgrading to production
# This script removes sample data loaded during trial evaluation
# 
# WARNING: This permanently deletes data. Ensure all valuable data has been backed up.
# See ../docs/managed-services-backup.md for backup requirements.
#
# Usage: ./cleanup-trial-data.ps1 -ResourceGroupName "mycompany-dev-rg" -Environment "dev"

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [switch]$ConfirmDelete
)

# Suppress progress bars for cleaner output
$ProgressPreference = "SilentlyContinue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Trial Data Cleanup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: This script will DELETE trial sample data permanently." -ForegroundColor Red
Write-Host "Ensure all valuable data has been backed up before proceeding." -ForegroundColor Red
Write-Host "See: docs/managed-services-backup.md for backup procedures." -ForegroundColor Red
Write-Host ""

if (-not $ConfirmDelete) {
    $confirm = Read-Host "Do you want to continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Connecting to Azure..." -ForegroundColor Green
$context = Get-AzContext
if ($null -eq $context) {
    Write-Host "Not logged in. Please run: Connect-AzAccount"
    exit 1
}

Write-Host "Using subscription: $($context.Subscription.Name)" -ForegroundColor Gray

# Get storage accounts
Write-Host ""
Write-Host "Retrieving storage accounts from resource group: $ResourceGroupName" -ForegroundColor Green

$dataLakeStorage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name "*dls*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $dataLakeStorage) {
    Write-Host "Data Lake storage account not found." -ForegroundColor Yellow
    $dataLakeStorage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Select-Object -First 1
}

if ($null -eq $dataLakeStorage) {
    Write-Host "No storage accounts found in resource group." -ForegroundColor Red
    exit 1
}

Write-Host "Found Data Lake storage: $($dataLakeStorage.StorageAccountName)" -ForegroundColor Gray

# Clean up Data Lake sample blobs
Write-Host ""
Write-Host "Cleaning up Data Lake sample blobs..." -ForegroundColor Green

$containers = @("raw", "refined", "processed", "shared")
$storageContext = $dataLakeStorage.Context

foreach ($container in $containers) {
    try {
        $blobs = Get-AzStorageBlob -Container $container -Context $storageContext -ErrorAction SilentlyContinue
        if ($blobs.Count -gt 0) {
            Write-Host "  Container '$container': $($blobs.Count) blob(s)"
            # Uncomment to delete blobs
            # $blobs | Remove-AzStorageBlob -Force
            Write-Host "    (To delete, uncomment line in script)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  Container '$container': Not found or empty" -ForegroundColor Gray
    }
}

# Get SQL Server and Database
Write-Host ""
Write-Host "Cleaning up SQL sample data..." -ForegroundColor Green

$sqlServers = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($sqlServers.Count -gt 0) {
    foreach ($sqlServer in $sqlServers) {
        Write-Host "  SQL Server: $($sqlServer.ServerName)" -ForegroundColor Gray
        
        $databases = Get-AzSqlDatabase -ServerName $sqlServer.ServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        foreach ($database in $databases) {
            if ($database.DatabaseName -ne "master") {
                Write-Host "    Database: $($database.DatabaseName)" -ForegroundColor Gray
                Write-Host "      To truncate sample tables, execute the following in SQL Server Management Studio:" -ForegroundColor Cyan
                Write-Host "      TRUNCATE TABLE [dbo].[SampleTable1];" -ForegroundColor Gray
                Write-Host "      TRUNCATE TABLE [dbo].[SampleTable2];" -ForegroundColor Gray
                Write-Host "      -- List all tables: SELECT name FROM sys.tables WHERE type='U';" -ForegroundColor Gray
            }
        }
    }
}
else {
    Write-Host "  No SQL servers found." -ForegroundColor Yellow
}

# Fabric workspace cleanup instructions
Write-Host ""
Write-Host "Cleaning up Fabric sample workspaces..." -ForegroundColor Green
Write-Host "  Manual step: Remove sample workspaces from Fabric Portal:" -ForegroundColor Cyan
Write-Host "    1. Go to Fabric Portal (https://fabric.microsoft.com)" -ForegroundColor Gray
Write-Host "    2. Click 'Workspaces'" -ForegroundColor Gray
Write-Host "    3. Find 'Trial' or sample workspaces" -ForegroundColor Gray
Write-Host "    4. Click '...' menu and select 'Delete'" -ForegroundColor Gray

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Data Lake blobs identified (manual deletion required)" -ForegroundColor Yellow
Write-Host "✓ SQL sample data identified (manual truncate required)" -ForegroundColor Yellow
Write-Host "✓ Fabric workspaces require manual deletion from Fabric Portal" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Green
Write-Host "1. Review data identified above" -ForegroundColor Gray
Write-Host "2. Ensure backups are complete (see docs/managed-services-backup.md)" -ForegroundColor Gray
Write-Host "3. Execute SQL TRUNCATE statements in your database" -ForegroundColor Gray
Write-Host "4. Delete Fabric workspaces from Fabric Portal" -ForegroundColor Gray
Write-Host "5. Contact eGroup at sales@egroup-us.com to upgrade to Initial/Production tier" -ForegroundColor Green
Write-Host ""
