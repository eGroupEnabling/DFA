## Overview

Costs for the Data Foundation Accelerator depend on region, chosen Fabric SKU,
SQL tier, storage volume, and the optional services you enable. This document
keeps the guidance directional on purpose: exact pricing drifts faster than the
template lifecycle, so use Azure pricing tools for current numbers.

## Directional Starting Points

These example monthly ranges are based on the current template footprint and
should be treated as planning guidance rather than quoted pricing.

| Deployment path | Typical monthly range | Main drivers |
|-----------------|-----------------------|--------------|
| `none` | $80-$160 | SQL Database, storage, transactions, bandwidth |
| `initial` (`F2`) | $600-$750 | Fabric `F2`, SQL Database, storage |
| `production` (`F4`) | $1,100-$1,350 | Fabric `F4`, SQL Database, storage, optional add-ons |

Additional Fabric SKUs above `F4` increase cost substantially and should be
priced directly in the Azure calculator.

## Largest Cost Drivers

- Fabric capacity if the deployment creates a new capacity
- Azure SQL Database tier and performance settings
- ADLS Gen2 data volume, transactions, and egress
- API Management if enabled
- Defender for Cloud paid plans if enabled

## Estimate Your Deployment

Use the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
for current pricing.

Add these services to the calculator as applicable:

1. Microsoft Fabric capacity for the chosen SKU
2. Azure SQL Database
3. Azure Storage account
4. Azure Key Vault
5. Azure API Management if enabled
6. Azure Functions if API ingestion is enabled
7. Microsoft Defender for Cloud if you plan to use the paid option

When you compare scenarios, change one variable at a time: region, Fabric SKU,
private connectivity choices, or optional services. That makes it much easier
to explain the cost delta to stakeholders.

## Cost Governance

After deployment, use Azure Cost Management to track actual spend:

- Create a monthly budget for the deployment resource group.
- Alert at multiple thresholds such as 50%, 80%, and 100% of budget.
- Review costs by service name so you can isolate whether Fabric, SQL,
  storage, or optional services are driving the variance.