
locals {  

  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs_private) : length(var.private_subnets)
}
################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = var.VPC_Name
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  map_public_ip_on_launch         = true

  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs_public, count.index))) > 0 ? element(var.azs_public, count.index) : null

  tags = {
      Name = "public subnet ${count.index} [${element(var.azs_public, count.index)}]"
    }
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = element(concat(var.private_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs_private, count.index))) > 0 ? element(var.azs_private, count.index) : null


  tags = {
      Name = "private subnet ${count.index} [${element(var.azs_private, count.index)}]"
    }
}
################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id                          = aws_vpc.main.id
  route {
      cidr_block = "0.0.0.0/0" 
      gateway_id = aws_internet_gateway.main.id
  }
    
    tags = {
        Name = "Main public route"
    }
}
################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id                          = aws_vpc.main.id
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {
      Name = "Main private route [${count.index}]"
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "main" {

  vpc_id                          = aws_vpc.main.id

  tags = {
     Name = "internet gateway" 
    }
}


################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# NAT Gateway
################################################################################

locals {
  nat_gateway_ips = try(aws_eip.main[*].id, [])
}

resource "aws_eip" "main" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  vpc = true

  tags = {
      Name = "eip for nat ${count.index}"
    }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = {
      Name = "nat gateway ${count.index}"
    }
  depends_on = [aws_internet_gateway.main]
}



