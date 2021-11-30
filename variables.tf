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