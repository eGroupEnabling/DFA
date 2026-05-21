## Overview

The Data Foundation Accelerator deploys a governed Azure data foundation for
analytics and AI workloads. This public repository is intentionally scoped to
the assets that ship today: the Azure Marketplace offer, the ARM template,
the portal experience, and a small set of sample artifacts for validation and
ingestion patterns.

The solution provisions core Azure services for storage, security,
networking, and relational data, with optional services for API ingestion,
API governance, and Defender for Cloud configuration. When you choose the
`none` capacity option, the deployment skips Fabric capacity creation so you
can attach an existing capacity or activate a Fabric trial separately in the
Fabric portal.

## Deploy To Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/enablingtechnologiescorporation.datafoundationacceleratordfa1)

Use the marketplace entry point above to launch the solution template in the
Azure portal.

1. Select a subscription, resource group, and region.
2. Choose a Fabric capacity option: `none`, `initial`, or `production`.
3. Provide the requested customer contact details used for installation
   tracking by eGroup.
4. Review configuration options such as private endpoints, Defender for
   Cloud, API ingestion, API Management, and SQL credentials.
5. Start the deployment and monitor progress in the target resource group.

## Included Resources

- Optional Microsoft Fabric capacity deployment. `initial` deploys `F2`;
  `production` defaults to `F4` and supports SKU override up to `F2048`;
  `none` leaves Fabric capacity management outside this template.
- Azure Virtual Network with a default subnet and an optional private
  endpoints subnet.
- Azure Data Lake Storage Gen2 account with `raw`, `ingestion`, `archive`,
  `function-host`, and `function-data` containers.
- Azure Key Vault for secrets and deployment configuration.
- Azure SQL Server and Azure SQL Database for governed relational storage.
- Optional Defender for Cloud configuration applied at the subscription
  scope.
- Optional API ingestion Function App for external API collection.
- Optional API Management instance for governed downstream consumption.

## Documentation

- [Deployment Guide](docs/deployment-guide.md) for prerequisites, portal flow,
  optional source-based deployment, validation, and cleanup.
- [Architecture Overview](docs/architecture.md) for the current deployed
  topology and data flow.
- [Cost Estimation](docs/cost-estimation.md) for budgeting guidance and cost
  drivers.
- [Troubleshooting](docs/troubleshooting.md) for common deployment and access
  issues.
- [Support](SUPPORT.md) for support scope and contact paths.

The deployment guide also covers direct template deployment from
`src/mainTemplate.json` for validation and automation scenarios, including the
required customer contact fields and the current optional capacity settings.

## Sample Labs

The repository includes optional walkthroughs that build on the deployed
foundation and the sample files in `samples/labs/`:

- [DFA01: SQL inventory walkthrough](docs/labs/DFA01-sql-inventory.md)
- [DFA02: CSV ingestion walkthrough](docs/labs/DFA02-csv-ingestion.md)
- [DFA03: Public API JSON walkthrough](docs/labs/DFA03-api-json.md)
- [DFA04: Power BI report walkthrough](docs/labs/DFA04-powerbi-report.md)
- [DFA05: Cost monitoring walkthrough](docs/labs/DFA05-cost-monitoring.md)

## Licensing

This solution template is provided under the [MIT License](LICENSE).
