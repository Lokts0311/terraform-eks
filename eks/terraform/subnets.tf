# Subnets
resource "aws_subnet" "private_zone1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr[0]
    availability_zone = var.zone[0]

    tags = {
        Name = "${var.env}-private-${var.zone[0]}"

        # Tags required for AWS Load Balancer Controller automatically discover subnet
        # https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
        # https://repost.aws/knowledge-center/eks-vpc-subnet-discovery
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
    }
}

resource "aws_subnet" "private_zone2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr[1]
    availability_zone = var.zone[1]

    tags = {
        Name = "${var.env}-private-${var.zone[1]}"

        # Tags for private subnet should be "kubernetes.io/role/internal-elb"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
    }
}

resource "aws_subnet" "public_zone1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr[2]
    availability_zone = var.zone[0]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.env}-public-${var.zone[0]}"

        # Tags for public subnet should be "kubernetes.io/role/elb"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
    }
}

resource "aws_subnet" "public_zone2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr[3]
    availability_zone = var.zone[1]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.env}-public-${var.zone[1]}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
    }
}