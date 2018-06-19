provider "kubernetes" {
  version = "~> 1.1"

  host                   = "${var.k8s_host}"
  client_certificate     = "${base64decode("${var.k8s_client_certificate}")}"
  client_key             = "${base64decode("${var.k8s_client_key}")}"
  cluster_ca_certificate = "${base64decode("${var.k8s_cluster_ca_certificate}")}"
}

module "push_user" {
  source = "github.com/lsst-sqre/tf_aws_iam_user"

  name = "${var.env_name}-eups-push"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}/*"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}"
    }
  ]
}
EOF
}

module "pull_user" {
  source = "github.com/lsst-sqre/tf_aws_iam_user"

  name = "${var.env_name}-eups-pull"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}/*"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}"
    }
  ]
}
EOF
}

module "backup_user" {
  source = "github.com/lsst-sqre/tf_aws_iam_user"

  name = "${var.env_name}-eups-backup"

  # read-only from eups bucket and read/write (without delete) to eups-backup
  # bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}/*"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}"
    },
    {
      "Sid": "3",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.eups_backups.arn}/*"
    },
    {
      "Sid": "4",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups_backups.arn}"
    }
  ]
}
EOF
}

module "tag_admin_user" {
  source = "github.com/lsst-sqre/tf_aws_iam_user"

  name = "${var.env_name}-eups-tag-admin"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGet",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}/*"
    },
    {
      "Sid": "AllowListingObjects",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups.arn}"
    },
    {
      "Sid": "AllowCopyButProtectSrc",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.eups.arn}/stack/src/tags/*.list",
        "${aws_s3_bucket.eups.arn}/stack/osx/*.list",
        "${aws_s3_bucket.eups.arn}/stack/redhat/*.list"
      ],
      "Condition": {
        "ForAnyValue:StringLike": {
          "s3:x-amz-copy-source": [
            "${aws_s3_bucket.eups.id}/stack/src/tags/*.list",
            "${aws_s3_bucket.eups.id}/stack/osx/*.list",
            "${aws_s3_bucket.eups.id}/stack/redhat/*.list"
          ]
        }
      }
    },
    {
      "Sid": "AllowDeleteButProtectSrc",
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.eups.arn}/stack/src/tags/*.list",
        "${aws_s3_bucket.eups.arn}/stack/osx/*.list",
        "${aws_s3_bucket.eups.arn}/stack/redhat/*.list"
      ]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "eups" {
  region = "${var.aws_default_region}"
  bucket = "${replace("${var.env_name}-eups.${var.domain_name}", "prod-", "")}"
  acl    = "private"

  versioning {
    enabled = false
  }

  force_destroy = false
}

# the bucket postfix is "-backups" (note the plural) to be consistent with what
# other sqre devs have done while the non-plural is used in tf resource names.
resource "aws_s3_bucket" "eups_backups" {
  region = "${var.aws_default_region}"
  bucket = "${aws_s3_bucket.eups.id}-backups"
  acl    = "private"

  # lifecycle rules still need to handle versioned object to work with buckets
  # on which versioning has been disabled (suspended)
  versioning {
    enabled = false
  }

  force_destroy = false

  lifecycle_rule {
    id      = "daily"
    enabled = true
    prefix  = "daily/"

    expiration {
      days = 8
    }

    noncurrent_version_expiration {
      days = 8
    }
  }

  lifecycle_rule {
    id      = "weekly"
    enabled = true
    prefix  = "weekly/"

    expiration {
      days = 35
    }

    noncurrent_version_expiration {
      days = 35
    }
  }

  # note that
  # * STANDARD-IA has a min cost size of 128KiB per object -- transistion
  # supposedly will not migrate objects < 128KiB
  # * GLACIER adds 8KiB for "metadata" per object
  # * min days before transition is 30 for non-versioned / current objects
  lifecycle_rule {
    id      = "monthly"
    enabled = true
    prefix  = "monthly/"

    expiration {
      days = 217
    }

    noncurrent_version_expiration {
      days = 217
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}
