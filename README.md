terraform / kubernetes / s3 deployment of HTTPS publishing for EUPS_PKGROOT(s)
===

tl;dr
---

    bundle install
    bundle exec rake eyaml:sqre
    bundle exec rake eyaml:decrypt
    bundle exec rake gcloud:disk
    bundle exec rake terraform:install
    bundle exec rake terraform:s3:apply
    bundle exec rake terraform:s3:s3sync-secret
    bundle exec rake khelper:create
    bundle exec rake khelper:ip
    bundle exec rake terraform:dns:apply

Deployment
---

### Install Gems

    bundle install

### Setup SQRE eyaml keyring

    bundle exec rake eyaml:sqre
    bundle exec rake eyaml:decrypt

### create gcloud persistent disk

    bundle exec rake gcloud:disk

### create s3 bucket + iam role users

    bundle exec rake terraform:install
    bundle exec rake terraform:s3:apply

### write s3 access kubernetes secretss

    bundle exec rake terraform:s3:s3sync-secret

### create kubernetes deployment

    bundle exec rake khelper:create

Note that this may take signifigant time to converge.  The next step may not be executed until

    kubectl get services nginx-ssl-proxy

returns an external IP address.

### write kubernetes service external IP address to `service_ip.txt`

    bundle exec rake khelper:ip

### route53 DNS records

    bundle exec rake terraform:dns:apply

Cleanup
---

    bundle exec rake destroy
