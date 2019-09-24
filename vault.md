vault setup
===

Secret root path is:

    "secret/dm/square/${var.deploy_name}/${var.env_name}/<secret>"

k8s deployment secrets
---

Required secrets are:

* `grafana_oauth` github oauth application credentials
  Example github callback url `https://${ENV_NAME}-grafana-${DEPLOY_NAME}.lsst.codes/login/github`
  * `client_id`
  * `client_secret`
* `prometheus_oauth` github oauth application credentials
  Example github callback url `https://${ENV_NAME}-prometheus-${DEPLOY_NAME}.codes/oauth2`
  * `client_id`
  * `client_secret`
* `tls` TLS public/private certs
  * `crt`
  * `key`

```bash
export ENV_NAME=foo
export DEPLOY_NAME=scipipe-publish
export TG_REPO=<path to terragrunt repo clone>

# generate github oauth callback urls
echo "grafana oauth2 callback url is https://${ENV_NAME}-grafana-${DEPLOY_NAME}.lsst.codes/login/github"
echo "prometheus oauth2 callback url https://${ENV_NAME}-prometheus-${DEPLOY_NAME}.codes/oauth2"

# try not to leak secrets into  shell history
unset HISTFILE

# push secrets to vault
vault kv put secret/dm/square/${DEPLOY_NAME}/${ENV_NAME}/grafana_oauth client_id= client_secret=

vault kv put secret/dm/square/${DEPLOY_NAME}/${ENV_NAME}/prometheus_oauth client_id= client_secret=

vault kv put secret/dm/square/${DEPLOY_NAME}/${ENV_NAME}/tls crt=@${TG_REPO}//lsst-certs/lsst.codes/2019/lsst.codes_chain.pem key=@${TG_REPO}/lsst-certs/lsst.codes/2019/lsst.codes.key
```
