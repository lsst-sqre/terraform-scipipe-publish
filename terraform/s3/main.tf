terraform {
  backend "s3" {}
}

module "push-user" {
  source = "../modules/iam_user"

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

module "pull-user" {
  source = "../modules/iam_user"

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

module "backup-user" {
  source = "../modules/iam_user"

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
      "Resource": "${aws_s3_bucket.eups-backups.arn}/*"
    },
    {
      "Sid": "4",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.eups-backups.arn}"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "eups" {
  region = "${var.aws_default_region}"
  bucket = "${replace("${var.env_name}-eups.${var.domain_name}", "prod-", "")}"
  acl    = "private"

  force_destroy = false
}

# the bucket postfix is "-backups" (note the plural) to be consistent with what
# other sqre devs have done while the non-plural is used in tf resource names.
resource "aws_s3_bucket" "eups-backups" {
  region = "${var.aws_default_region}"
  bucket = "${aws_s3_bucket.eups.id}-backups",
  acl    = "private"

  force_destroy = false

  lifecycle_rule {
    id      = "daily"
    enabled = true
    prefix  = "daily/"

    expiration {
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
  }

  # note that
  # * STANDARD-IA has a min cost size of 128KiB per object -- transistion
  # supposedly will not migrate objects < 128KiB
  # * GLACIER adds 8KiB for "metadata" per object
  # * min days before transition is 30 for non-versioned / current objects
  lifecycle_rule {
    id      = "monthly"
    enabled = true
    prefix  = "montly/"

    expiration {
      days = 217
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}
