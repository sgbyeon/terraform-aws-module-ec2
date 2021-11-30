# AWS private EC2 Terraform custom module
* AWS 에서 private EC2를 생성하는 기본 모듈
* ebs 기본 암호(기본키 사용, 선택불가)

## Usage

### `terraform.tfvars`
* 모든 변수는 적절하게 변경하여 사용
```
account_id = ["123456789012"] # 아이디 변경 필수, output 확인용, 실수 방지용도, 리소스에 사용하진 않음
region = "ap-northeast-2" # 리전 변경 필수, output 확인용, 실수 방지용도, 리소스에 사용하진 않음
instance_name = "bsg-eks-bastion" # ec2 instance 이름
ami_id = "ami-0f2c95e9fe3f8f80e" # Amazon Linux 2 AMI (HVM), SSD Volume Type
instance_type = "t3.small"
key_name = "demo-eks-key"
volume_type = "gp3"
volume_size = 20

# ec2 를 위치 시킬 vpc 태크 필요
vpc_filters = {
  "Name" = "bsg-demo-eks-vpc"
}

# ec2에서 사용할 서브넷 대역의 태그 필요
subnet_filters = {
  "Name" = "bsg-demo-eks-vpc-ap-northeast-2a-public-bastion-sn"
}

# ec2 에 SSH 접속을 위한 sg rule
sg_ingress_rule = [ "111.111.111.111/32" ] # 접속 허용 IP

# 공통 tag, 생성되는 모든 리소스에 태깅
tags = {
    "CreatedByTerraform" = "true"
}
```
---

### `main.tf`
```
module "ec2" {
  source = "git::https://github.com/sgbyeon/terraform-aws-module-ec2.git"
  account_id = var.account_id
  region = var.region
  instance_name = var.instance_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  volume_type = var.volume_type
  volume_size = var.volume_size
  vpc_id = data.aws_vpc.this.id
  subnet_id = data.aws_subnet.this.id
  sg_ingress_rule = var.sg_ingress_rule
  tags = var.tags
}
```
---
### `data.tf`
```
data "aws_region" "current" {}

data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.vpc_filters # block를 생성할 정보를 담은 collection 전달, 전달 받은 수 만큼 block 생성
    iterator = tag # 각각의 item 에 접근할 수 있는 라벨링 부여, content block에서 tag 를 사용하여 접근
    
    content { # block안에서 실제 전달되는 값들
      name = "tag:${tag.key}"
      values = [
        tag.value
      ]
    }
  }
}

data "aws_subnet" "this" {
  vpc_id = data.aws_vpc.this.id
  dynamic "filter" {
    for_each = var.subnet_filters
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
variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type = list(string)
  default = [""]
}

variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "vpc_filters" {
  description = "Filters to select vpc"
  type = map(string)
}

variable "subnet_filters" {
  description = "Filters to select subnets"
  type = map(string)
}

variable "instance_name" {
  description = "EC2 instance name"
  type = string
}

variable "ami_id" {
  description = "AMI - Amazon Linux 2 (default)"
  type = string
  default = "ami-0f2c95e9fe3f8f80e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = ""
}

variable "key_name" {
  description = "Key Name to use for ec2 instance"
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

variable "sg_ingress_rule" {
  description = "Ingress Security Group rule"
  type = list(string)
  default = []
}

variable "subnet_id" {
  description = "Bastion subnet"
  type = string
  default = ""
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
  default = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}
```
---

### `outputs.tf`
```
output "account_id" {
  description = "AWS Account ID"
  value = module.ec2.account_id
}

output "vpc_id" {
  description = "VPC ID"
  value = module.ec2.vpc_id
}

output "instance_name" {
  description = "EC2 instance name"
  value = module.ec2.instance_name
}

output "instance_type" {
  description = "EC2 instance type"
  value = module.ec2.instance_type
}

output "root_device" {
  description = "EC2 instance type"
  value = module.ec2.root_device
}

output "subnet" {
  description = "EC2 instance type"
  value = module.ec2.subnet
}
```