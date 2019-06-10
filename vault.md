vault setup
===

Secret root path is:

    "secret/dm/square/scipipe-publish/${var.env_name}/<secret>"

Example:

k8s deployment secrets
---

vault kv put secret/dm/square/scipipe-publish/jhoblitt-curly/grafana_oauth client_id= client_secret=

vault kv put secret/dm/square/scipipe-publish/jhoblitt-curly/grafana_admin user= pass=

vault kv put secret/dm/square/scipipe-publish/jhoblitt-curly/prometheus_oauth client_id= client_secret=

vault kv put secret/dm/square/scipipe-publish/jhoblitt-curly/tls crt=@/home/jhoblitt/github/terragrunt-live-test/lsst-certs/lsst.codes/2018/lsst.codes.pem key=@/home/jhoblitt/github/terragrunt-live-test/lsst-certs/lsst.codes/2018/lsst.codes.key
