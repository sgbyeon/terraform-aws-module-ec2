resource "aws_eip" "this" {
  vpc = true
  tags = merge(var.tags, tomap({Name = format("%s.eip", var.instance_name)}))
}

resource "aws_instance" "this" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index = 0
  }

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  depends_on = [
    aws_eip.this
  ]

  tags = merge(var.tags, tomap({Name = format("%s", var.instance_name)}))
}

resource "aws_eip_association" "this" {
  instance_id = aws_instance.this.id
  allocation_id = aws_eip.this.id

  depends_on = [
    aws_instance.this
  ]
}

resource "aws_network_interface" "this" {
  description = "NIC eth0 for ${var.instance_name}"
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.this.id]

  tags = merge(var.tags, tomap({Name = format("%s.nic", var.instance_name)}))
}

# ebs는 kms 기본키로 암호화, 선택아닌 필수
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}