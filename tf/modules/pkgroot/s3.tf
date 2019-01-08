locals {
  #pkgroot_bucket      = "${local.fqdn}-${var.aws_primary_region}"
  pkgroot_bucket      = "${local.fqdn}"
  pkgroot_logs_bucket = "${local.pkgroot_bucket}-logs"

  # the bucket postfix is "-backups" (note the plural) to be consistent with
  # what other sqre devs have done while the non-plural is used in tf resource
  # names.
  pkgroot_backups_bucket = "${local.pkgroot_bucket}-backups"

  pkgroot_backups_logs_bucket = "${local.pkgroot_backups_bucket}-logs"
}

resource "aws_s3_bucket" "eups" {
  region        = "${var.aws_primary_region}"
  bucket        = "${local.pkgroot_bucket}"
  acl           = "private"
  force_destroy = false

  versioning {
    enabled = false
  }

  logging {
    target_bucket = "${aws_s3_bucket.pkgroot_logs.id}"
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket_metric" "pkgroot" {
  bucket = "${aws_s3_bucket.eups.bucket}"
  name   = "EntireBucket"
}

resource "aws_s3_bucket" "pkgroot_logs" {
  region        = "${var.aws_primary_region}"
  bucket        = "${local.pkgroot_logs_bucket}"
  acl           = "log-delivery-write"
  force_destroy = false
}

resource "aws_s3_bucket" "eups_backups" {
  region        = "${var.aws_primary_region}"
  bucket        = "${local.pkgroot_backups_bucket}"
  acl           = "private"
  force_destroy = false

  # lifecycle rules still need to handle versioned object to work with buckets
  # on which versioning has been disabled (suspended)
  versioning {
    enabled = false
  }

  logging {
    target_bucket = "${aws_s3_bucket.pkgroot_backups_logs.id}"
    target_prefix = "log/"
  }

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

resource "aws_s3_bucket_metric" "pkgroot_backups" {
  bucket = "${aws_s3_bucket.eups_backups.bucket}"
  name   = "EntireBucket"
}

resource "aws_s3_bucket" "pkgroot_backups_logs" {
  region        = "${var.aws_primary_region}"
  bucket        = "${local.pkgroot_backups_logs_bucket}"
  acl           = "log-delivery-write"
  force_destroy = false
}
