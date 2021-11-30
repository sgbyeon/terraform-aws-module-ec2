output "account_id" {
  description = "AWS Account ID"
  value = var.account_id
}

output "vpc_id" {
  description = "VPC ID"
  value = var.vpc_id
}

output "instance_name" {
  description = "EC2 instance ID"
  value = var.instance_name
}

output "instance_type" {
  description = "EC2 instance type"
  value = aws_instance.this.instance_type
}

output "root_device" {
  description = "EC2 instance type"
  value = aws_instance.this.root_block_device
}

output "subnet" {
  description = "EC2 instance type"
  value = aws_instance.this.subnet_id
}