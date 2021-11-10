# AWS VPC Terraform custom module
* AWS 에서 private EC2를 생성하는 기본 모듈
* public은 지원하지 않음

## Usage

### `terraform.tfvars`
* 모든 변수는 적절하게 변경하여 사용
```
account_id = ["123456789012"] 
region = "ap-northeast-2"
ec2_name = "bsg"
ami_id = "ami-0f2c95e9fe3f8f80e" # Amazon Linux 2 (default)
instance_type = "t3.small"
volume_type = "gp3"
volume_size = 20

vpc_filters = {
  "Name" = "" # ec2를 위치시킬 vpc의 이름
}

private_subnet_filters = {
  "Name" = "" # ec2를 위치시킬 서브넷의 tag name 지정
}

# ec2 에 SSH 접속을 위한 sg rule
ec2_ingress_sg_rule = [ "10.10.0.0/24", "10.20.0.0/24" ]

# 공통 tag, 생성되는 모든 리소스에 태깅
tags = {
    "CreatedByTerraform" = "true"
}
```
---

### `main.tf`
```
module "bastion" {
  source = "git::https://github.com/sgbyeon/terraform-aws-module-ec2"
  ec2_name = var.ec2_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  volume_type = var.volume_type
  volume_size = var.volume_size
  vpc_id = data.aws_vpc.eks_vpc.id
  subnet_id = data.aws_subnet.public.id
  ec2_ingress_sg_rule = var.ec2_ingress_sg_rule
  tags = var.tags
}
}
```
---
### `data.tf`
```
data "aws_region" "current" {}

data "aws_vpc" "ec2" {
  dynamic "filter" {
    for_each = var.vpc_filters
    iterator = tag
    content {
      name = "tag:${tag.key}"
      values = [
        tag.value
      ]
    }
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.ec2.id
  dynamic "filter" {
    for_each = var.private_subnet_filters
    iterator = tag
    content {
      name = "tag:${tag.key}"
      values = [
        tag.value
      ]
    }
  }
}
```

### `provider.tf`
```
provider  "aws" {
  region  =  var.region
}
```
---

### `terraform.tf`
```
terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.39"
    }
  }
}
```
---

### `variables.tf`
```
variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type = list(string)
  default = [""]
}

variable "ec2_name" {
  description = "Name of ec2 instance"
  type = string
}

variable "vpc_filters" {
  description = "Filters to select subnets"
  type = map(string)
}

variable "private_subnet_filters" {
  description = "Filters to select private subnets"
  type = map(string)
}

variable "ami_id" {
  description = "AMI - Amazon Linux 2"
  type = string
  default = "ami-0f2c95e9fe3f8f80e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = ""
}

variable "volume_type" {
  description = "The type of volume. (gp2, io1, io2, standard)"
  type = string
  default = ""
}

variable "volume_size" {
  description = "The size of the volume in gigabytes" 
  type = number
}

variable "ec2_ingress_sg_rule" {
  description = "Ingress Security Group rule for Bastion"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}
```
---

### `outputs.tf`
```
output "id" {
  description = "EC2 instance ID"
  value = module.ec2.id
}

output "type" {
  description = "EC2 instance type"
  value = module.ec2.type
}

output "root_device" {
  description = "EC2 root device"
  value = module.ec2.root_deivce
}

output "subnet" {
  description = "EC2 instance subnet"
  value = module.ec2.subnet
}
```