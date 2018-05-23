provider "aws" {
  region = "${var.aws_region}"
}

#----------Default VPC----------
resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

#----------Default security group----------
resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name = "Default security group"
}
}

#----------Default Subnet----------
resource "aws_default_subnet" "default1" {
  availability_zone = "us-east-2a"

  tags {
    Name = "Default Subnet"
  }
}

resource "aws_default_subnet" "default2" {
  availability_zone = "us-east-2b"

  tags {
    Name = "Default Subnet"
  }
}

#----------Security group----------
resource "aws_security_group" "tf-aws-web-security-group" {
  name = "tf-aws-web-security-group"
  description = "Allow all traffic"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tf-aws-web-security-group"
  }
}

#----------EC2----------
resource "aws_instance" "tf-aws-web-ec2" {
  ami = "${var.ami}"
  count = "${var.instances_count}"
  instance_type = "t2.micro"
  subnet_id = "${aws_default_subnet.default1.id}"
  vpc_security_group_ids = ["${aws_security_group.tf-aws-web-security-group.id}"]
  key_name = "${var.key_name}"
  associate_public_ip_address = true

  tags {
    Name = "tf-aws-web-ec2"
  }
}

#----------ALB target group----------
resource "aws_lb_target_group" "tf-aws-web-tg" {
  name = "tf-aws-web-tg"
  port = "80"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name = "tf-aws-web-tg"
  }
}

#----------EC2 attachment to target groups----------
resource "aws_lb_target_group_attachment" "tf-aws-web-tg-attachment" {
  target_group_arn = "${aws_lb_target_group.tf-aws-web-tg.arn}"
  count = "${var.instances_count}"
  target_id = "${element(aws_instance.tf-aws-web-ec2.*.id, count.index)}"
}

#----------ALB----------
resource "aws_lb" "tf-aws-web-lb" {
  name = "tf-aws-web-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.tf-aws-web-security-group.id}", "${aws_default_security_group.default.id}"]
  subnets = ["${aws_default_subnet.default1.id}", "${aws_default_subnet.default2.id}"]

  tags {
    Name = "tf-aws-web-lb"
  }
}

#----------LB listener----------
resource "aws_lb_listener" "tf-aws-web-listener" {
  load_balancer_arn = "${aws_lb.tf-aws-web-lb.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.tf-aws-web-tg.arn}"
    type = "forward"
  }
}
