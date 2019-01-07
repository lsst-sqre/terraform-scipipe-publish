deployment for publishing eups packages (EUPS_PKGROOT) + doxygen generated html
===

[![Build
Status](https://travis-ci.org/lsst-sqre/terraform-scipipe-publish.png)](https://travis-ci.org/lsst-sqre/terraform-scipipe-publish)

Usage
---

See [terraform-doc output](tf/README.md) for available arguments and
attributes.

tl;dr
---

    bundle install
    bundle exec rake creds
    # edit TF_VAR_env_name=<env name> in creds.sh
    . creds.sh

    cd tf
    make tf-init-s3
    make tls
    ./bin/terraform plan
    ./bin/terraform apply

Deployment
---

### Install Gems

    bundle install

### Setup env vars / aws credentials

    bundle exec rake creds
    . creds.sh

Note that `creds.sh` will need to be manually edited unless these env vars are
present when the rake task is run:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

### Bootstrap `terraform` / create s3 bucket for remote state

    cd tf
    make tf-init-s3

### Clone tls certs / generate DH parameters

    make tls

### Run `terraform`

    ./bin/terraform plan
    ./bin/terraform apply

`pre-commit` hooks
---

```bash
go get github.com/segmentio/terraform-docs
pip install --user pre-commit
pre-commit install

# manual run
pre-commit run -a
```

See also
---

* [`terraform`](https://www.terraform.io/)
* [`terragrunt`](https://github.com/gruntwork-io/terragrunt)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs)
* [`pre-commit`](https://github.com/pre-commit/pre-commit)
* [`pre-commit-terraform`](https://github.com/antonbabenko/pre-commit-terraform)
