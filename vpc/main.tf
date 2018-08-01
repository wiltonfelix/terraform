data "aws_availability_zones" "default" {}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}-${var.region}"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "internet-gateway-${var.region}"
  }

  depends_on = ["aws_vpc.default"]
}

resource "aws_eip" "nat_gateway_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "public-route-${var.region}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(split(",", var.public_subnet_cidr), count.index)}"
  availability_zone = "${element(data.aws_availability_zones.default.names, count.index)}"
  count             = "${length(split(",", var.public_subnet_cidr))}"
  depends_on        = ["aws_internet_gateway.default"]

  tags {
    Name = "public-subnet-${element(data.aws_availability_zones.default.names, count.index)}"
  }

  lifecycle {
    create_before_destroy = false
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.public_subnet_cidr))}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.*.id[0]}"
  depends_on    = ["aws_internet_gateway.default", "aws_subnet.public_subnet"]
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(split(",", var.private_subnet_cidr), count.index)}"
  availability_zone = "${element(data.aws_availability_zones.default.names, count.index)}"
  count             = "${length(split(",", var.private_subnet_cidr))}"

  tags {
    Name = "private-subnet-${element(data.aws_availability_zones.default.names, count.index)}"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "private-route-${var.region}"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.private_subnet_cidr))}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"

  lifecycle {
    create_before_destroy = false
  }
}
