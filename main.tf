# Configuration du provider AWS
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuration pour Terraform Cloud
  cloud {
    organization = "Myne_William"
    
    workspaces {
      name = "Terraform-aws-dev"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "cloud-${var.student_number}-VPC"
    Environment = "Training"
    Project     = "INF1097"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "cloud-${var.student_number}-IGW"
    Project = "INF1097"
  }
}

# Sous-réseau Public - Bastion (eu-west-2a)
resource "aws_subnet" "public_bastion" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_bastion_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "net-public-bastion"
    Type    = "Public"
    Project = "INF1097"
  }
}

# Sous-réseau Privé - Servers (eu-west-2b)
resource "aws_subnet" "private_servers" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_servers_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name    = "net-private-servers"
    Type    = "Private"
    Project = "INF1097"
  }
}

# Sous-réseau Privé - Databases (eu-west-2a)
# Note: Marqué comme "Public" dans le PDF mais devrait être privé pour les bases de données
resource "aws_subnet" "private_databases" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_databases_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "net-private-databases"
    Type    = "Private"
    Project = "INF1097"
  }
}

# Sous-réseau Public - DMZ Web (eu-west-2c)
resource "aws_subnet" "dmz_web" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_dmz_web_cidr
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = {
    Name    = "net-dmz-web"
    Type    = "Public"
    Project = "INF1097"
  }
}

# Sous-réseau Privé - Applications (eu-west-2b)
resource "aws_subnet" "private_apps" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_apps_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name    = "net-private-apps"
    Type    = "Private"
    Project = "INF1097"
  }
}

# Table de routage publique
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "cloud-${var.student_number}-public-rt"
    Type    = "Public"
    Project = "INF1097"
  }
}

# Association de la table de routage avec net-public-bastion
resource "aws_route_table_association" "public_bastion" {
  subnet_id      = aws_subnet.public_bastion.id
  route_table_id = aws_route_table.public.id
}

# Association de la table de routage avec net-dmz-web
resource "aws_route_table_association" "dmz_web" {
  subnet_id      = aws_subnet.dmz_web.id
  route_table_id = aws_route_table.public.id
}

# Table de routage privée (utilise la route par défaut du VPC)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "cloud-${var.student_number}-private-rt"
    Type    = "Private"
    Project = "Aws_infrastructure"
  }
}

# Associations pour les sous-réseaux privés
resource "aws_route_table_association" "private_servers" {
  subnet_id      = aws_subnet.private_servers.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_databases" {
  subnet_id      = aws_subnet.private_databases.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_apps" {
  subnet_id      = aws_subnet.private_apps.id
  route_table_id = aws_route_table.private.id
}
