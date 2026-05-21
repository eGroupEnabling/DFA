#!/usr/bin/env bash
#
# Clean up trial sample data before upgrading to production
# This script removes sample data loaded during trial evaluation
# 
# WARNING: This permanently deletes data. Ensure all valuable data has been backed up.
# See ../docs/managed-services-backup.md for backup requirements.
#
# Usage: ./cleanup-trial-data.sh -r mycompany-dev-rg -e dev
#

set -e

# Parse arguments
RESOURCE_GROUP=""
ENVIRONMENT="dev"
CONFIRM=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -c|--confirm)
            CONFIRM=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$RESOURCE_GROUP" ]; then
    echo "Error: Resource group name required (-r or --resource-group)"
    exit 1
fi

echo "========================================"
echo "Trial Data Cleanup Script"
echo "========================================"
echo ""
echo -e "\033[31mWARNING: This script will DELETE trial sample data permanently.\033[0m"
echo -e "\033[31mEnsure all valuable data has been backed up before proceeding.\033[0m"
echo "See: docs/managed-services-backup.md for backup procedures."
echo ""

# Confirm deletion
if [ "$CONFIRM" = false ]; then
    read -p "Do you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "\033[33mOperation cancelled.\033[0m"
        exit 0
    fi
fi

echo -e "\033[32mConnecting to Azure...\033[0m"
CURRENT_SUBSCRIPTION=$(az account show --query name -o tsv 2>/dev/null || echo "")
if [ -z "$CURRENT_SUBSCRIPTION" ]; then
    echo "Not logged in. Please run: az login"
    exit 1
fi
echo "Using subscription: $CURRENT_SUBSCRIPTION"

# Get storage accounts
echo ""
echo -e "\033[32mRetrieving storage accounts from resource group: $RESOURCE_GROUP\033[0m"

# Find Data Lake storage account
STORAGE_ACCOUNT=$(az storage account list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'dls')].name" -o tsv | head -1)

if [ -z "$STORAGE_ACCOUNT" ]; then
    # Fallback: get first storage account
    STORAGE_ACCOUNT=$(az storage account list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[0].name" -o tsv)
fi

if [ -z "$STORAGE_ACCOUNT" ]; then
    echo -e "\033[31mNo storage accounts found in resource group.\033[0m"
    exit 1
fi

echo "Found Data Lake storage: $STORAGE_ACCOUNT"

# Clean up Data Lake sample blobs
echo ""
echo -e "\033[32mCleaning up Data Lake sample blobs...\033[0m"

CONTAINERS=("raw" "refined" "processed" "shared")
for container in "${CONTAINERS[@]}"; do
    BLOB_COUNT=$(az storage blob list \
        --account-name "$STORAGE_ACCOUNT" \
        --container-name "$container" \
        --query 'length(@)' -o tsv 2>/dev/null || echo "0")
    
    if [ "$BLOB_COUNT" -gt 0 ]; then
        echo "  Container '$container': $BLOB_COUNT blob(s)"
        echo "    To delete all blobs, run:"
        echo "    az storage blob delete-batch --account-name $STORAGE_ACCOUNT --source $container"
    fi
done

# Get SQL Server and Database
echo ""
echo -e "\033[32mCleaning up SQL sample data...\033[0m"

SQL_SERVERS=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
if [ -n "$SQL_SERVERS" ]; then
    for server in $SQL_SERVERS; do
        echo "  SQL Server: $server"
        
        DATABASES=$(az sql db list --resource-group "$RESOURCE_GROUP" --server "$server" --query "[?name!='master'].name" -o tsv)
        for database in $DATABASES; do
            echo "    Database: $database"
            echo "      To truncate sample tables, execute the following in Azure Data Studio or SQL Server Management Studio:"
            echo "      TRUNCATE TABLE [dbo].[SampleTable1];"
            echo "      TRUNCATE TABLE [dbo].[SampleTable2];"
            echo "      -- List all tables: SELECT name FROM sys.tables WHERE type='U';"
        done
    done
else
    echo "  No SQL servers found."
fi

# Fabric workspace cleanup instructions
echo ""
echo -e "\033[32mCleaning up Fabric sample workspaces...\033[0m"
echo "  Manual step: Remove sample workspaces from Fabric Portal:"
echo "    1. Go to Fabric Portal (https://fabric.microsoft.com)"
echo "    2. Click 'Workspaces'"
echo "    3. Find 'Trial' or sample workspaces"
echo "    4. Click '...' menu and select 'Delete'"

# Summary
echo ""
echo "========================================"
echo "Cleanup Summary"
echo "========================================"
echo "✓ Data Lake blobs identified (manual deletion required)"
echo "✓ SQL sample data identified (manual truncate required)"
echo "✓ Fabric workspaces require manual deletion from Fabric Portal"
echo ""
echo -e "\033[32mNext Steps:\033[0m"
echo "1. Review data identified above"
echo "2. Ensure backups are complete (see docs/managed-services-backup.md)"
echo "3. Execute SQL TRUNCATE statements in your database"
echo "4. Delete Fabric workspaces from Fabric Portal"
echo "5. Contact eGroup at sales@egroup-us.com to upgrade to Initial/Production tier"
echo ""
