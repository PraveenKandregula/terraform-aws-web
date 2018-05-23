output "VPC_ID" {
  value = "${aws_default_vpc.default.id}"
}

output "SUBNET1_ID" {
  value = "${aws_default_subnet.default1.id}"
}

output "SUBNET2_ID" {
  value = "${aws_default_subnet.default2.id}"
}

output "EC2_ID" {
  value = "${aws_instance.tf-aws-web-ec2.*.id}"
}

output "EC2_PUBLIC_DNS" {
  value = "${aws_instance.tf-aws-web-ec2.*.public_dns}"
}

output "SECURITY_GROUP_ID" {
  value = "${aws_security_group.tf-aws-web-security-group.id}"
}

output "LB_DNS" {
#  value = "${aws_lb.tf-aws-web-lb.dns_name}"
  value = "${aws_lb.tf-aws-web-lb.dns_name}"
}
