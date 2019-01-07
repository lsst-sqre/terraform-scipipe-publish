# terraform-scipipe-publish

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_access\_key | AWS access key id. | string | n/a | yes |
| aws\_default\_region | AWS region to launch servers. | string | `"us-east-1"` | no |
| aws\_secret\_key | AWS secret access key. | string | n/a | yes |
| aws\_zone\_id | route53 Hosted Zone ID to manage DNS records in. | string | `"Z3TH0HRSNU67AM"` | no |
| deploy\_name | Name of deployment. | string | `"publish-release"` | no |
| domain\_name | DNS domain name to use when creating route53 records. | string | `"lsst.codes"` | no |
| env\_name | Name of deployment environment. | string | n/a | yes |
| google\_project | google cloud project ID | string | `"plasma-geode-127520"` | no |

## Outputs

| Name | Description |
|------|-------------|
| DOXYGEN\_FQDN |  |
| DOXYGEN\_PUSH\_AWS\_ACCESS\_KEY\_ID |  |
| DOXYGEN\_PUSH\_AWS\_SECRET\_ACCESS\_KEY |  |
| DOXYGEN\_PUSH\_USER |  |
| DOXYGEN\_S3\_BUCKET |  |
| EUPS\_BACKUP\_AWS\_ACCESS\_KEY\_ID |  |
| EUPS\_BACKUP\_AWS\_SECRET\_ACCESS\_KEY |  |
| EUPS\_BACKUP\_S3\_BUCKET |  |
| EUPS\_BACKUP\_USER |  |
| EUPS\_FQDN |  |
| EUPS\_PULL\_AWS\_ACCESS\_KEY\_ID |  |
| EUPS\_PULL\_AWS\_SECRET\_ACCESS\_KEY |  |
| EUPS\_PULL\_USER |  |
| EUPS\_PUSH\_AWS\_ACCESS\_KEY\_ID |  |
| EUPS\_PUSH\_AWS\_SECRET\_ACCESS\_KEY |  |
| EUPS\_PUSH\_USER |  |
| EUPS\_S3\_BUCKET |  |
| EUPS\_TAG\_ADMIN\_AWS\_ACCESS\_KEY\_ID |  |
| EUPS\_TAG\_ADMIN\_AWS\_SECRET\_ACCESS\_KEY |  |
| EUPS\_TAG\_ADMIN\_USER |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
