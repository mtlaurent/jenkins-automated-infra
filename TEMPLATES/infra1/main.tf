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
resource "aws_subnet" "INFRANAME-SUBNET-PRIVATE" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.2.0/24"
        tags = {
                Name = "INFRANAME-SUBNET-PRIVATE"
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
resource "aws_route_table_association" "INFRANAME-RTB-PRIVATE-ASSOC" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PRIVATE.id}"
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
resource "aws_security_group" "INFRANAME-SG-PRIVATE" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.INFRANAME-SG-PUBLIC.id}"]
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
resource "aws_instance" "INFRANAME-INSTANCE-PRIVATE" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PRIVATE.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-PRIVATE.id}"]
        associate_public_ip_address = false
        tags = {
                Name = "INFRANAME-INSTANCE-PRIVATE"
        }
}