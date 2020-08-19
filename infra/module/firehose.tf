resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "${var.system_name}-s3-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose.arn
    bucket_arn          = data.aws_s3_bucket.application_logs_bucket.arn
    buffer_interval     = "900"
    buffer_size         = "128"
    compression_format  = "GZIP"
    prefix              = "${var.system_name}/!{timestamp:yyyy/MM/dd/HH}/logs_"
    error_output_prefix = "${var.system_name}/!{timestamp:yyyy/MM/dd/HH}/error_!{firehose:error-output-type}"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = "S3Delivery"
    }

    processing_configuration {
      enabled = false
    }
  }

  server_side_encryption {
    enabled = false
  }
}

data "aws_s3_bucket" "application_logs_bucket" {
  bucket = var.application_logs_bucket
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/${var.system_name}-s3-firehose"
  retention_in_days = 3
}

resource "aws_iam_role" "firehose" {
  name               = "KinesisFirehoseServiceRole-${var.system_name}"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_policy.json
}

data "aws_iam_policy_document" "firehose_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "firehose" {
  name = "KinesisFirehoseServicePolicy-${var.system_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::juv-shun.application-logs",
                "arn:aws:s3:::juv-shun.application-logs/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn}:log-stream:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose.arn
}
