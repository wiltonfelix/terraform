output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "vpc_range" {
  value = "${aws_vpc.default.cidr_block}"
}

output "subnet_public_ids" {
  value = "${join(",", aws_subnet.public_subnet.*.id)}"
}

output "subnet_private_ids" {
  value = "${join(",", aws_subnet.private_subnet.*.id)}"
}
