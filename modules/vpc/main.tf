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

resource "aws_subnet" "private" {
  count             = "${var.subnets["private"]}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.default.names,
    (count.index % length(data.aws_availability_zones.default.names)))}"

  tags {
    Name = "${format("%v-private-%02d", var.vpc_name, count.index+1)}"
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

resource "aws_subnet" "public" {
  count                   = "${var.subnets["public"]}"
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 
    count.index + var.subnets["private"])}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.default.names,
    (count.index % length(data.aws_availability_zones.default.names)))}"

  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "${format("%v-public-%02d", var.vpc_name, count.index+1)}"
  }

  lifecycle {
    create_before_destroy = false
  }
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

resource "aws_route_table_association" "public" {
  count             = "${var.subnets["public"]}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.default", "aws_subnet.public"]
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
  count             = "${var.subnets["private"]}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"

  lifecycle {
    create_before_destroy = false
  }
}
