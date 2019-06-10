# terraform-scipipe-publish

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_primary\_region | AWS region to launch servers. | string | `"us-east-1"` | no |
| aws\_zone\_id | route53 Hosted Zone ID to manage DNS records in. | string | n/a | yes |
| deploy\_name | Name of deployment. | string | `"scipipe-publish"` | no |
| dns\_enable | create route53 dns records. | string | `"false"` | no |
| dns\_overwrite | overwrite pre-existing DNS records. | string | `"false"` | no |
| domain\_name | DNS domain name to use when creating route53 records. | string | n/a | yes |
| env\_name | Name of deployment environment. | string | n/a | yes |
| gke\_version | gke master/node version | string | `"latest"` | no |
| google\_project | google cloud project ID | string | n/a | yes |
| google\_region | google cloud region | string | `"us-central1"` | no |
| google\_zone | google cloud region/zone | string | `"us-central1-b"` | no |
| grafana\_oauth\_client\_id | github oauth Client ID for grafana | string | `""` | no |
| grafana\_oauth\_client\_secret | github oauth Client Secret for grafana. | string | `""` | no |
| grafana\_oauth\_team\_ids | github team id (integer value treated as string) | string | `"1936535"` | no |
| pkgroot\_storage\_size | Size of gcloud persistent volume claim. E.g.: 200Gi or 1Ti | string | `"10Gi"` | no |
| prometheus\_oauth\_client\_id | github oauth client id | string | `""` | no |
| prometheus\_oauth\_client\_secret | github oauth client secret | string | `""` | no |
| prometheus\_oauth\_github\_org | limit access to prometheus dashboard to members of this org | string | `"lsst-sqre"` | no |
| storage\_class | Storage class to be used for all persistent disks. For a deployment on k3s use 'local-path'. | string | `"pd-ssd"` | no |
| tls\_crt\_path | wildcard tls certificate. | string | n/a | yes |
| tls\_key\_path | wildcard tls private key. | string | n/a | yes |

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
| grafana\_admin\_pass | grafana admin user account password. |
| grafana\_admin\_user | name of the grafana admin user account. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
