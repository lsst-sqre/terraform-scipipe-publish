module "push_user" {
  source = "git::https://github.com/lsst-sqre/terraform-aws-iam-user"

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
  source = "git::https://github.com/lsst-sqre/terraform-aws-iam-user"

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
  source = "git::https://github.com/lsst-sqre/terraform-aws-iam-user"

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
  source = "git::https://github.com/lsst-sqre/terraform-aws-iam-user"

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
