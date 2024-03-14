#creating vpc
resource "aws_vpc" "vpc1" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = "false"

  tags = {
    Name = "vpc-lab1"
  }

}
#creating public subnet
resource "aws_subnet" "public" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name= "public subnet "
  }
  
}
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Internet-gateway"
  }
}
#creating routing table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc1.id
  route  {
    cidr_block= "0.0.0.0/0"
    gateway_id= aws_internet_gateway.gw.id

  }
  
  tags = {
    Name="route table"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}

#creating security group allow ports 443,22
resource "aws_security_group" "webserver" {
  name = "webserver-sg"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks =["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

#creating EC2 with apache web server 
resource "aws_instance" "web" {
  ami             = "ami-005e54dee72cc1d00" 
  instance_type   = var.instance_type
  key_name        = var.instance_key
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.webserver.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web_instance"
  } 
  volume_tags = {
    Name = "web_instance"
  } 
}

