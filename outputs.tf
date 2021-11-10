output "id" {
  description = "EC2 instance ID"
  value = aws_instance.this.id
}

output "type" {
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