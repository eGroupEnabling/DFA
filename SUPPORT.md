## Support Scope

This repository documents the Azure Marketplace offer, the deployment templates, and the sample assets. It does not define contractual service levels, managed backup operations, workshop scope, or other engagement-specific terms.

Use the public documentation first:

- [Deployment Guide](docs/deployment-guide.md)
- [Architecture Overview](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Cost Estimation](docs/cost-estimation.md)

## Contact Paths

- Technical support: [techops@egroup-us.com](mailto:techops@egroup-us.com)
- Support request form: [eGroup support portal](https://www.egroup-us.com/request-support/)
- Sales and commercial questions: [sales@egroup-us.com](mailto:sales@egroup-us.com)
- General company contact: [info@egroup-us.com](mailto:info@egroup-us.com)

## What To Include In A Support Request

Include enough deployment context to reproduce or triage the problem quickly:

- Offer or template version: `1.0.1`
- Azure subscription, resource group, and region
- Deployment tier: `none`, `initial`, or `production`
- Whether private endpoints, Defender for Cloud, API ingestion, or API
   Management were enabled
- The exact error text, deployment operation name, and any relevant activity
   log details

## Operational Notes

- If you selected `none`, Fabric capacity is managed outside this template.
   Activate a Fabric trial or attach an existing capacity separately in the
   Fabric portal.
- If you enabled Defender for Cloud configuration, the deployment changes
   pricing plans at the subscription scope rather than only inside the target
   resource group.
- If you enabled private endpoints, validate DNS and network pathing before
   treating data-plane connectivity problems as service outages.

## Scope Boundary

Managed services, backup policies, SLAs, and escalation paths can vary by
commercial agreement. Those terms will be provided in any contracts or service
documentation rather than in this public repository.
