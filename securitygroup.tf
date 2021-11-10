resource "aws_security_group" "this" {
  name = "${var.ec2_name}-sg"
  description = "${var.ec2_name} security group"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({Name = format("%s-sg", var.ec2_name)}))
}

resource "aws_security_group_rule" "this" {
  description = "remote connection with SSH for admin"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = var.ec2_ingress_sg_rule
  security_group_id = aws_security_group.this.id
}