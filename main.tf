# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.main.id
  availability_zone = "ap-south-1b"
  tags = {
    Name = "public"
  }
}

# Create a private subnet
resource "aws_subnet" "private" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.main.id
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT Gateway"
  }
}

# Create a security group for the public subnet
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for the private subnet
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  vpc      = true
}

# Associate the Elastic IP with the NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami           = "ami-05e00961530ae1b55"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id = aws_subnet.public.id
  key_name               = "mykey"
  associate_public_ip_address = true  # Assigns a public IP address to this instance
}

# Create an EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  ami           = "ami-05e00961530ae1b55"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id = aws_subnet.private.id
  key_name               = "mykey"
}
