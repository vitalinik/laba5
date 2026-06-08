locals {
  ssh_security_group_name          = "${var.resource_prefix}-ssh-sg"
  public_http_security_group_name  = "${var.resource_prefix}-public-http-sg"
  private_http_security_group_name = "${var.resource_prefix}-private-http-sg"

  common_tags = {
    Project = var.project_id
  }
}

data "aws_network_interface" "public" {
  filter {
    name   = "attachment.instance-id"
    values = [var.public_instance_id]
  }

  filter {
    name   = "attachment.device-index"
    values = ["0"]
  }
}

data "aws_network_interface" "private" {
  filter {
    name   = "attachment.instance-id"
    values = [var.private_instance_id]
  }

  filter {
    name   = "attachment.device-index"
    values = ["0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = local.ssh_security_group_name
  description = "Allow SSH and ICMP access from approved IP ranges."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = local.ssh_security_group_name
  })
}

resource "aws_security_group" "public_http" {
  name        = local.public_http_security_group_name
  description = "Allow public HTTP and ICMP access from approved IP ranges."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = local.public_http_security_group_name
  })
}

resource "aws_security_group" "private_http" {
  name        = local.private_http_security_group_name
  description = "Allow private HTTP and ICMP access from the public HTTP security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = local.private_http_security_group_name
  })
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh.id
  description       = "Allow SSH from approved IP ranges."
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "ssh_icmp_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh.id
  description       = "Allow ICMP from approved IP ranges."
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "public_http_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.public_http.id
  description       = "Allow HTTP from approved IP ranges."
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "public_http_icmp_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.public_http.id
  description       = "Allow ICMP from approved IP ranges."
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_http.id
  description              = "Allow HTTP from the public HTTP security group."
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
}

resource "aws_security_group_rule" "private_http_icmp_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_http.id
  description              = "Allow ICMP from the public HTTP security group."
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.public_http.id
}

resource "aws_security_group_rule" "ssh_egress" {
  type              = "egress"
  security_group_id = aws_security_group.ssh.id
  description       = "Allow all outbound traffic."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_http_egress" {
  type              = "egress"
  security_group_id = aws_security_group.public_http.id
  description       = "Allow all outbound traffic."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "private_http_egress" {
  type              = "egress"
  security_group_id = aws_security_group.private_http.id
  description       = "Allow all outbound traffic."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_network_interface_sg_attachment" "public_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_network_interface.public.id
}

resource "aws_network_interface_sg_attachment" "public_http" {
  security_group_id    = aws_security_group.public_http.id
  network_interface_id = data.aws_network_interface.public.id
}

resource "aws_network_interface_sg_attachment" "private_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_network_interface.private.id
}

resource "aws_network_interface_sg_attachment" "private_http" {
  security_group_id    = aws_security_group.private_http.id
  network_interface_id = data.aws_network_interface.private.id
}
