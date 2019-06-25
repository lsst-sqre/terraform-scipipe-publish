vault setup
===

Secret root path is:

    "secret/dm/square/scipipe-publish/${var.env_name}/<secret>"

k8s deployment secrets
---

Required secrets are:

* `grafana_oauth`
    Example github callback url https://${ENV_NAME}-grafana-scipipe-publish.lsst.codes/login/github
* `prometheus_oauth`
    Example github callback url https://${ENV_NAME}-prometheus-scipipe-publish.lsst.codes/oauth2
* `tls`

```bash
export ENV_NAME=jhoblitt-moe
vault kv put secret/dm/square/scipipe-publish/${ENV_NAME}/grafana_oauth client_id= client_secret=

vault kv put secret/dm/square/scipipe-publish/${ENV_NAME}/grafana_admin user= pass=

vault kv put secret/dm/square/scipipe-publish/${ENV_NAME}/prometheus_oauth client_id= client_secret=

vault kv put secret/dm/square/scipipe-publish/${ENV_NAME}/tls crt=@/home/jhoblitt/github/terragrunt-live-test/lsst-certs/lsst.codes/2018/lsst.codes_chain.pem key=@/home/jhoblitt/github/terragrunt-live-test/lsst-certs/lsst.codes/2018/lsst.codes.key
```
