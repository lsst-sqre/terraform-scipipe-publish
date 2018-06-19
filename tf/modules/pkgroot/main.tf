provider "aws" {
  version = "~> 1.21"
}

provider "kubernetes" {
  version = "~> 1.1"

  host                   = "${var.k8s_host}"
  client_certificate     = "${base64decode("${var.k8s_client_certificate}")}"
  client_key             = "${base64decode("${var.k8s_client_key}")}"
  cluster_ca_certificate = "${base64decode("${var.k8s_cluster_ca_certificate}")}"
}

provider "template" {
  version = "~> 1.0"
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
