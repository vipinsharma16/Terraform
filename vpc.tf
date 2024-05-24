resource "aws_vpc" "bmt-rat-eks-VPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true" #gives you an internal domain name
  enable_dns_support = "true"   #gives you an internal host name

  tags = {
    Name = "${var.EKSClusterName}-VPC"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "PublicSubnet01" {
  vpc_id     = aws_vpc.bmt-rat-eks-VPC.id
  cidr_block = var.PublicSubnet01Block
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

    tags = {
        Name = "${var.EKSClusterName}-PublicSubnet01"
        "kubernetes.io/role/elb" = "1"
    }
}

resource "aws_subnet" "PublicSubnet02" {
  vpc_id     = aws_vpc.bmt-rat-eks-VPC.id
  cidr_block = var.PublicSubnet02Block
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

    tags = {
        Name = "${var.EKSClusterName}-PublicSubnet02"
        "kubernetes.io/role/elb" = "1"
    }
}

resource "aws_subnet" "PrivateSubnet01" {
  vpc_id     = aws_vpc.bmt-rat-eks-VPC.id
  cidr_block = var.PrivateSubnet01Block
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

    tags = {
        Name = "${var.EKSClusterName}-PrivateSubnet01"
        "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_subnet" "PrivateSubnet02" {
  vpc_id     = aws_vpc.bmt-rat-eks-VPC.id
  cidr_block = var.PrivateSubnet02Block
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

    tags = {
        Name  = "${var.EKSClusterName}-PrivateSubnet02"
        "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_internet_gateway" "bmt-rat-igw" {
  vpc_id = aws_vpc.bmt-rat-eks-VPC.id

  tags = {
    Name = "${var.EKSClusterName}-igw"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.bmt-rat-eks-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bmt-rat-igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "Public-Route-Asso-1" {
  subnet_id      = aws_subnet.PublicSubnet01.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "Public-Route-Asso-2" {
  subnet_id      = aws_subnet.PublicSubnet02.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_eip" "NatGatewayEIP1" {
    domain = "vpc"

 tags = {
    name = "NatGatewayEIP1"
 }
}

resource "aws_eip" "NatGatewayEIP2" {
    domain = "vpc"

 tags = {
    name = "NatGatewayEIP2"
 }
}

resource "aws_nat_gateway" "NatGateway01" {
  allocation_id = aws_eip.NatGatewayEIP1.id
  subnet_id     = aws_subnet.PublicSubnet01.id

  tags = {
    Name = "NatGateway01"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.bmt-rat-igw]
}

resource "aws_nat_gateway" "NatGateway02" {
  allocation_id = aws_eip.NatGatewayEIP2.id
  subnet_id     = aws_subnet.PublicSubnet02.id

  tags = {
    Name = "NatGateway02"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.bmt-rat-igw]
}

resource "aws_route_table" "PrivateRouteTable01" {
  vpc_id = aws_vpc.bmt-rat-eks-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NatGateway01.id
  }

  tags = {
    Name = "PrivateRouteTable01"
  }
}

resource "aws_route_table" "PrivateRouteTable02" {
  vpc_id = aws_vpc.bmt-rat-eks-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NatGateway02.id
  }

  tags = {
    Name = "PrivateRouteTable02"
  }
}

resource "aws_route_table_association" "PrivateRoute-asso-1" {
  subnet_id      = aws_subnet.PrivateSubnet01.id
  route_table_id = aws_route_table.PrivateRouteTable01.id
}

resource "aws_route_table_association" "PrivateRoute-asso-2" {
  subnet_id      = aws_subnet.PrivateSubnet02.id
  route_table_id = aws_route_table.PrivateRouteTable02.id
}

resource "aws_security_group" "ControlPlaneSecurityGroup" {
  name        = "ControlPlaneSecurityGroup"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.bmt-rat-eks-VPC.id

    
   ingress {
      description = "allow"
      protocol = "-1"
      self = true
      from_port = 0
      to_port = 0
   }

   tags = {
      Name = "${var.EKSClusterName}-ControlPlaneSecurityGroup"
   }
}

resource "aws_vpc_security_group_egress_rule" "outbond_rule" {
  security_group_id = aws_security_group.ControlPlaneSecurityGroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description = "allow to all"
}

