terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "ca-central-1"
}

resource "aws_instance" "micro" {
    ami           = "ami-0abac8735a38475db"
    instance_type = "t3.micro"

    tags = {
        Name = "terraform-ec2-micro"
    }
}

output "instance_id" {
    value       = aws_instance.micro.id
    description = "The ID of the EC2 instance"
}

output "public_ip" {
    value       = aws_instance.micro.public_ip
    description = "The public IP address of the instance"
}