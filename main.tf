terraform {
    required_version = "~> 1.3"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
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