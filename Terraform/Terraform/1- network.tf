# VPC
resource "aws_vpc" "firefly_vpc" {
  cidr_block           = "10.0.0.0/16" # Defines the IP range for the VPC
  enable_dns_hostnames = true          # Enables DNS hostnames within the VPC
  enable_dns_support   = true          # Enables DNS resolution within the VPC
  tags = {
    Name = "firefly_main_vpc" # Tags the VPC with a name for identification
  }
}

# Public subnet
resource "aws_subnet" "firefly-public-subnet" {
  tags = {
    Name = "firefly_public_subnet" # Tags the subnet with a name for identification
  }
  cidr_block = "10.0.1.0/24"          # Defines the IP range for the public subnet
  vpc_id     = aws_vpc.firefly_vpc.id # Associates the subnet with the VPC
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "firefly-igw" {
  tags = {
    Name = "firefly-igw" # Tags the Internet Gateway with a name for identification
  }
  vpc_id = aws_vpc.firefly_vpc.id # Associates the Internet Gateway with the VPC
}

# Route table for the public subnet
resource "aws_route_table" "firefly-public-route-table" {
  vpc_id = aws_vpc.firefly_vpc.id # Associates the route table with the VPC
  tags = {
    Name = "public-firefly-route-table" # Tags the route table with a name for identification
  }
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.firefly-public-route-table.id # Associates the route with the route table
  gateway_id             = aws_internet_gateway.firefly-igw.id           # Specifies the Internet Gateway for the route
  destination_cidr_block = "0.0.0.0/0"                                   # Routes all traffic (0.0.0.0/0) through the Internet Gateway
}

# Associate the newly created route table to the public subnet
resource "aws_route_table_association" "firefly-public-route-association" {
  route_table_id = aws_route_table.firefly-public-route-table.id # Associates the route table with the public subnet
  subnet_id      = aws_subnet.firefly-public-subnet.id           # Specifies the subnet to associate with the route table
}
