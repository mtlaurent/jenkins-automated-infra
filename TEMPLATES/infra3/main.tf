terraform {
        required_providers {
                aws = {
                        source  = "hashicorp/aws"
                }
        }
}
provider "aws" {
        region = "us-east-1"
}
resource "aws_vpc" "INFRANAME-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "INFRANAME-VPC"
        }
}
resource "aws_subnet" "INFRANAME-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "INFRANAME-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "INFRANAME-SUBNET-AZ-A" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.2.0/24"
        availability_zone = "us-east-1a"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-A"
        }
}
resource "aws_subnet" "INFRANAME-SUBNET-AZ-B" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.3.0/24"
        availability_zone = "us-east-1b"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-B"
        }
}
resource "aws_subnet" "INFRANAME-SUBNET-AZ-C" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.4.0/24"
        availability_zone = "us-east-1c"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-C"
        }
}
resource "aws_internet_gateway" "INFRANAME-IGW" {
        tags = {
                Name = "INFRANAME-IGW"
        }
}
resource "aws_internet_gateway_attachment" "INFRANAME-IGW-ATTACH" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.INFRANAME-IGW.id}"
}
resource "aws_route_table" "INFRANAME-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.INFRANAME-IGW.id}"
        }
        tags = {
                Name = "INFRANAME-RTB-PUBLIC"
        }
}
resource "aws_eip" "INFRANAME-EIP" {
}
resource "aws_nat_gateway" "INFRANAME-NATGW" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        allocation_id = "${aws_eip.INFRANAME-EIP.id}"
        tags = {
                Name = "INFRANAME-NATGW"
        }
}
resource "aws_route_table" "INFRANAME-RTB-PRIVATE" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = "${aws_nat_gateway.INFRANAME-NATGW.id}"
        }
        tags = {
                Name = "INFRANAME.RTB-PRIVATE"
        }
}
resource "aws_route_table_association" "INFRANAME-RTB-PRIVATE-ASSOC1" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-A.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PRIVATE-ASSOC2" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-B.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PRIVATE-ASSOC3" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-C.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PRIVATE.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PUBLIC.id}"
}
resource "aws_security_group" "INFRANAME-SG-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-PUBLIC"
        }
}
resource "aws_security_group" "INFRANAME-SG-LOAD-BALANCER" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-LOAD-BALANCER"
        }
}
resource "aws_security_group" "INFRANAME-SG-WEB" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.INFRANAME-SG-PUBLIC.id}"]
        }
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.INFRANAME-SG-LOAD-BALANCER.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-PUBLIC"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        tags = {
                Name = "INFRANAME-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-A" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-A.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-A"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-B" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-B.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-B"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-C" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-C.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-C"
        }
}
resource "aws_lb" "INFRANAME-LB" {
        name = "INFRANAME-LB"
        subnets = ["${aws_subnet.INFRANAME-SUBNET-AZ-A.id}", "${aws_subnet.INFRANAME-SUBNET-AZ-B.id}", "${aws_subnet.INFRANAME-SUBNET-AZ-C.id}"]
        security_groups = ["${aws_security_group.INFRANAME-SG-LOAD-BALANCER.id}"]
}
resource "aws_lb_target_group" "INFRANAME-LB-TG" {
        name = "INFRANAME-LB-TG"
        port = 80
        protocol = "HTTP"
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        target_type = "instance"
}
resource "aws_lb_target_group_attachment" "INFRANAME-LB-TG-ATTACH-1" {
        target_group_arn = "${aws_lb_target_group.INFRANAME-LB-TG.arn}"
        target_id = "${aws_instance.INFRANAME-INSTANCE-AZ-A.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "INFRANAME-LB-TG-ATTACH-2" {
        target_group_arn = "${aws_lb_target_group.INFRANAME-LB-TG.arn}"
        target_id = "${aws_instance.INFRANAME-INSTANCE-AZ-B.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "INFRANAME-LB-TG-ATTACH-3" {
        target_group_arn = "${aws_lb_target_group.INFRANAME-LB-TG.arn}"
        target_id = "${aws_instance.INFRANAME-INSTANCE-AZ-C.id}"
        port = 80
}
resource "aws_lb_listener" "INFRANAME-LB-LISTENER" {
        load_balancer_arn = "${aws_lb.INFRANAME-LB.arn}"
        port = "80"
        protocol = "HTTP"
        default_action {
                type = "forward"
                target_group_arn = "${aws_lb_target_group.INFRANAME-LB-TG.arn}"
        }
}