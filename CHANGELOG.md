All notable changes to the Data Foundation Accelerator are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-05-21

### Added

- Customer contact collection in the marketplace deployment experience for
  installation tracking
- Optional Fabric capacity administrator input for new Fabric capacity
  deployments

### Changed

- Unified the marketplace flow around the current `none`, `initial`, and
  `production` deployment tiers
- Consolidated repository documentation around the shipped marketplace offer,
  templates, and sample assets
- Updated the public README to use the Azure Marketplace deployment entry
  point

### Fixed

- Secured customer contact parameters in the deployment template
- Corrected Fabric SKU handoff in deployment automation
- Inlined marketplace deployment assets for packaged deployments
- Tightened portal-side SQL credential validation and removed stale trial
  script arguments

## [1.0.0] - 2026-02-03

### Added

- Initial release of Data Foundation Accelerator
- Support for three deployment tiers: Trial, Initial (F2), Production (F4–F2048)
- Microsoft Fabric Capacity provisioning
- Virtual Network with private connectivity options
- Data Lake Storage Gen2 with configurable access tiers
- Azure Key Vault for secrets management
- Azure SQL Database with configurable SKUs
- Storage Accounts for CSV and file ingestion
- API Management for data consumption governance
- Single-plan marketplace offering with UI-driven tier selection
- Parameterized resource naming using Microsoft CAF conventions
- Comprehensive deployment guide and architecture documentation
- Cost estimation reference for each tier and region
- Integration points for future Insights Factory Workshop modules
- Support for global Azure regions

### Known Limitations

- Deployment currently supports Standard and Premium Azure regions (not Government or China)
- Fabric capacity must be in the same region as supporting services
- Requires a minimum of Contributor role on the target resource group
