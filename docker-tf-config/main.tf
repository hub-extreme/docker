provider "aws" {
    region = "ap-south-1"
    access_key = ""
    secret_key = ""
  
}

variable "instance-count" {
    description = "it is the count of instance"
    type = number
    default = 1
  
}

variable "instance-type" {
    description = "the type of instance"
    type = string
    default = "t2.micro"
  
}

variable "cidr_block" {
    default = "192.0.0.0/16"
  
}

resource "aws_key_pair" "dock_keypair" {
    key_name = "dock_keypair"
    public_key = file("")
  
}

resource "aws_vpc" "dock-vpc" {
    cidr_block = var.cidr_block
  
}

resource "aws_internet_gateway" "dock_ig" {
    vpc_id = aws_vpc.dock-vpc.id
  
}

resource "aws_subnet" "dock_subnet_1" {
    vpc_id = aws_vpc.dock-vpc.id
    availability_zone = "ap-south-1a"
    cidr_block = "192.0.1.0/24"
    map_public_ip_on_launch = true

}

resource "aws_route_table" "dock_rt" {
    vpc_id = aws_vpc.dock-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dock_ig.id
    }
  
}

resource "aws_route_table_association" "dock_rt_assoc" {
    route_table_id = aws_route_table.dock_rt.id
    subnet_id = aws_subnet.dock_subnet_1.id
  
}

resource "aws_security_group" "dock_sg" {
    vpc_id = aws_vpc.dock-vpc.id
    name = "dock-sg"

    ingress {
        description = "allows ssh connection"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allows http connection"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "outgoing traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name="dock_sg"
    }
}

locals {
  name = "docker_server"
}

resource "aws_instance" "docker_server" {
    ami = ""
    instance_type = var.instance-type
    count = var.instance-count
    key_name = aws_key_pair.dock_keypair.key_name
    vpc_security_group_ids = [aws_security_group.dock_sg.id]
    subnet_id = aws_subnet.dock_subnet_1.id

    connection {
      host = self.public_ip
      user = "ubuntu"
      type = "ssh"
      private_key = file("")
    }


    provisioner "file" {
        source = "~/docker/dock-install.sh"
        destination = "/home/ubuntu/dock-install.sh"
      
    }

    provisioner "remote-exec" {
        inline = [ 
            "sudo apt-get update -y",
            "cd /home/ubuntu",
            "sudo chmod +x dock-install.sh",
            "bash dock-install.sh"
         ]
      
    }
}




