terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}


resource "aws_vpc" "ecs_chk_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-chk-vpc"
  }
}

resource "aws_subnet" "ecs_chk_subnet_1" {
  vpc_id            = aws_vpc.ecs_chk_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "ecs-chk-subnet-1"
  }
}

resource "aws_subnet" "ecs_chk_subnet_2" {
  vpc_id            = aws_vpc.ecs_chk_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "ecs-chk-subnet-2"
  }
}

resource "aws_subnet" "ecs_chk_subnet_3" {
  vpc_id            = aws_vpc.ecs_chk_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "ecs-chk-subnet-3"
  }
}

resource "aws_internet_gateway" "ecs_chk_ig" {
  vpc_id = aws_vpc.ecs_chk_vpc.id

  tags = {
    Name = "ecs_chk_ig"
  }
}

resource "aws_security_group" "ecs_chk_sg" {
  name        = "ecs-chk-sg"
  vpc_id      = aws_vpc.ecs_chk_vpc.id
  description = "SG for Web and Zabbix instances"

  dynamic "ingress" {
    for_each = [for rule in var.ingress_rules: {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
      description = rule.description
      self        = rule.self
    }]
    iterator = rule

    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = rule.value.cidr_blocks
      description = rule.value.description
      self        = rule.value.self
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.egress_rules: {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
      description = rule.description
      self        = rule.self
    }]
    iterator = rule

    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = rule.value.cidr_blocks
      description = rule.value.description
      self        = rule.value.self
    }
  }

  tags = {
    Name = "ecs_chk_sg"
  }
}

resource "aws_route_table" "ecs_chk_rt" {
  vpc_id = aws_vpc.ecs_chk_vpc.id

  tags = {
    Name = "ecs-chk-rt"
  }
}

resource "aws_route" "ecs_chk_default_route" {
  route_table_id         = aws_route_table.ecs_chk_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_chk_ig.id

  depends_on = [
    aws_route_table.ecs_chk_rt,
    aws_internet_gateway.ecs_chk_ig,
  ]
}

resource "aws_route_table_association" "ecs_chk_rt_association_1" {
  subnet_id      = aws_subnet.ecs_chk_subnet_1.id
  route_table_id = aws_route_table.ecs_chk_rt.id
}

resource "aws_route_table_association" "ecs_chk_rt_association_2" {
  subnet_id      = aws_subnet.ecs_chk_subnet_2.id
  route_table_id = aws_route_table.ecs_chk_rt.id
}

resource "aws_route_table_association" "ecs_chk_rt_association_3" {
  subnet_id      = aws_subnet.ecs_chk_subnet_3.id
  route_table_id = aws_route_table.ecs_chk_rt.id
}

# resource "aws_instance" "zbx-zabbix" {
#   ami                         = "ami-0fc20dd1da406780b"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.zbx-subnet-3.id
#   vpc_security_group_ids      = [aws_security_group.zbx-sg.id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name

#   tags = {
#     Name = "zbx-zabbix"
#   }
# }

# resource "aws_instance" "zbx-web" {
#   ami                         = "ami-0fc20dd1da406780b"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.zbx-subnet-1.id
#   vpc_security_group_ids      = [aws_security_group.zbx-sg.id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name

#   tags = {
#     Name = "zbx-web"
#   }
# }
