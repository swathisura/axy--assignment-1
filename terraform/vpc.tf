resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "axy-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}
