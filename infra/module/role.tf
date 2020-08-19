#####################################
# EC2Role
#####################################
resource "aws_iam_role" "instance_role" {
  name               = "${var.system_name}-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_policy.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.system_name}-instance-profile"
  path = "/"
  role = aws_iam_role.instance_role.id
}

resource "aws_iam_role_policy_attachment" "instance_role_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "instance_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#####################################
# TaskExecutionRole
#####################################
resource "aws_iam_role" "task_exe_role" {
  name               = "${var.system_name}-task-exe-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "task_exe_role_attachment" {
  role       = aws_iam_role.task_exe_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#####################################
# TaskRole
#####################################
resource "aws_iam_role" "task_role" {
  name               = "${var.system_name}-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}
resource "aws_iam_policy" "put_logs_to_firehose" {
  name = "EcsAccessKinesisFirehose-${var.system_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToS3BucketForSegmentationPush",
            "Effect": "Allow",
            "Action": [
              "firehose:PutRecordBatch"
            ],
            "Resource": [
               "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn}"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_task_policy_put_log_firehose" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.put_logs_to_firehose.arn
}
