terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "juv-shun.tfstate"
    key    = "trial-api-server/tfstate.tf"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "juv-shun.tfstate"
    key    = "foundation/network/tfstate.tf"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"

  config = {
    bucket = "juv-shun.tfstate"
    key    = "foundation/security/tfstate.tf"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket = "juv-shun.tfstate"
    key    = "foundation/s3/tfstate.tf"
    region = "ap-northeast-1"
  }
}

module "trial" {
  source      = "./module/"
  system_name = "trial"
  vpc_id      = data.terraform_remote_state.network.outputs.aws_vpc_subnet_ids["vpc"]
  subnet = {
    az1 = data.terraform_remote_state.network.outputs.aws_vpc_subnet_ids["public_subnet_az1"]
    az2 = data.terraform_remote_state.network.outputs.aws_vpc_subnet_ids["public_subnet_az2"]
  }
  access_logs_bucket      = data.terraform_remote_state.s3.outputs.fundamental_bucket["access_logs"]
  application_logs_bucket = data.terraform_remote_state.s3.outputs.fundamental_bucket["application_logs"]
  certificate_arn         = ""
  default_security_group  = data.terraform_remote_state.security.outputs.security_group_ids["default"]
  autoscaling_config = {
    max_instance_size = 2
    min_instance_size = 0
    desired_capacity  = 0
  }
  ec2_config = {
    image_id      = "ami-0763fff45988661c8"
    instance_type = "t2.micro"
  }
  key_pair = data.terraform_remote_state.security.outputs.general_key_pair
}
