
resource "aws_subnet" "private" {
  count = length(local.private_subnets) > 0 ? length(local.private_subnets) : 0

  vpc_id               = local.vpc_id
  cidr_block           = local.private_subnets[count.index]
  availability_zone    = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  tags = merge(
    {
      Name = "private-${element(local.azs, count.index)}"
    },
    local.private_subnet_tags,
  )
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id
  tags = {
    Name = "private-${var.region}"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_route_table_association" "private" {
  count = length(local.private_subnets) > 0 ? length(local.private_subnets) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

###########################################################

resource "aws_subnet" "public" {
  count = length(local.public_subnets) > 0 ? length(local.public_subnets) : 0

  vpc_id               = local.vpc_id
  cidr_block           = local.public_subnets[count.index]
  availability_zone    = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  tags = merge(
    {
      Name = "public-${element(local.azs, count.index)}"
    },
    local.public_subnet_tags,
  )
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id
  tags = {
    Name = "public-${var.region}"
  }
}

resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.internet_gateway_id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_subnets) > 0 ? length(local.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
