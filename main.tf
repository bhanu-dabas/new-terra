# Configure AWS provider
provider "aws" {
  region = "ap-south-1"  # Change to your desired region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  # Change to your desired CIDR block

  tags = {
    Name = "my_vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Attach internet gateway to VPC
resource "aws_vpc_attachment" "my_vpc_attachment" {
  vpc_id       = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway.my_igw.id
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"  # Change to your desired public subnet CIDR block
  availability_zone = "ap-south-1"   # Change to your desired availability zone

  tags = {
    Name = "public_subnet"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"  # Change to your desired private subnet CIDR block
  availability_zone = "ap-south-1"   # Change to your desired availability zone

  tags = {
    Name = "private_subnet"
  }
}

# Create security group for public instances
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
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

# Create security group for private instances
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.my_vpc.id

  # Add rules as needed for your application requirements
}

# Create public EC2 instance
resource "aws_instance" "public_instance" {
  ami                    = "ami-05e00961530ae1b55"  # Change to your desired AMI ID
  instance_type          = "t2.micro"      # Change to your desired instance type
  subnet_id              = aws_subnet.public_subnet.id
  security_groups        = [aws_security_group.public_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "mongo1"
  }
}

# Create private EC2 instance
resource "aws_instance" "private_instance" {
  ami                    = "ami-05e00961530ae1b55"  # Change to your desired AMI ID
  instance_type          = "t2.micro"      # Change to your desired instance type
  subnet_id              = aws_subnet.private_subnet.id
  security_groups        = [aws_security_group.private_sg.name]

  tags = {
    Name = "mongo2"
  }
}
