

# VPC resource
resource "aws_vpc" "vpc" {

    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "Infrastructure vpc"
    }
}


# subnet resource
resource "aws_subnet" "vpc_public_subnet" {

    vpc_id = aws_vpc.vpc.id

    availability_zone = "us-east-1a"

    cidr_block = "10.0.0.0/24"

    map_public_ip_on_launch = "true" 

    tags = {
        Name = "Infrastructure vpc public subnet"
    }
}

# subnet resource
resource "aws_subnet" "vpc_private_subnet" {

    vpc_id = aws_vpc.vpc.id

    availability_zone = "us-east-1a"

    map_public_ip_on_launch = "false" 
    
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "Infrastructure vpc private subnet"
    }
}

# VPC Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Infrastructure vpc internet gateway"
  }
}

# Elastic IP ===
resource "aws_eip" "nat_gateway_eip" {
  vpc      = true
}
# Nat Gateway ===
resource "aws_nat_gateway" "nat_gateway" {

  connectivity_type = "public"

  subnet_id         = aws_subnet.vpc_public_subnet.id

  # Required for connectivity_type of public
  allocation_id = aws_eip.nat_gateway_eip.id

}

# VPC route table
resource "aws_route_table" "public_subnet_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" # destination IP
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public subnet route table"
  }
}
# route table association
resource "aws_route_table_association" "vpc_public_subnet_route_table" {
  subnet_id      = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# VPC Route Table
resource "aws_route_table" "private_subnet_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id 
  }

  tags = {
    Name = "Private subnet route table"
  }
}
# Route Table Assocation
resource "aws_route_table_association" "vpc_private_subnet_route_table_assocation" {
  subnet_id      = aws_subnet.vpc_private_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}


# VPC Endpoint ===
resource "aws_vpc_endpoint" "dynamoDB_VPC_endpoint" {

  vpc_id       = aws_vpc.vpc.id

  service_name = "com.amazonaws.us-east-1.dynamodb"

  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "dynamoDB_VPC_endpoint"
  }
}
# VPC Endpoint Route Table Association
resource "aws_vpc_endpoint_route_table_association" "vpc_private_subnet_endpoint_assocation" {
  route_table_id  = aws_route_table.private_subnet_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamoDB_VPC_endpoint.id
}

