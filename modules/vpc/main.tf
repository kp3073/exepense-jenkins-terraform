resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index+1}"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
  tags = {
    name = "${var.env}-ngw"
  }
}


resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id = var.account_no
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = "true"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id =  aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "private"
  }
}

resource "aws_route" "default-route-tabel" {
  route_table_id            = var.default_vpc_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}