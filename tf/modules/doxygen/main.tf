provider "aws" {
  version = "~> 1.21"
}

module "push_user" {
  source = "github.com/lsst-sqre/tf_aws_iam_user"

  name = "${var.env_name}-doxygen-push"

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
      "Resource": "${aws_s3_bucket.doxygen.arn}/*"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Action": [
        "s3:ListObjects",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.doxygen.arn}"
    }
  ]
}
EOF
}
