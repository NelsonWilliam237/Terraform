# Variables pour la configuration AWS

variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "eu-west-2"
}

variable "student_number" {
  description = "Numéro d'étudiant pour nommer les ressources"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc CIDR pour le VPC"
  type        = string
  default     = "10.145.0.0/16"
}

variable "subnet_public_bastion_cidr" {
  description = "CIDR pour le sous-réseau public bastion"
  type        = string
  default     = "10.145.10.0/24"
}

variable "subnet_private_servers_cidr" {
  description = "CIDR pour le sous-réseau privé servers"
  type        = string
  default     = "10.145.200.0/24"
}

variable "subnet_private_databases_cidr" {
  description = "CIDR pour le sous-réseau privé databases"
  type        = string
  default     = "10.145.55.0/26"
}

variable "subnet_dmz_web_cidr" {
  description = "CIDR pour le sous-réseau DMZ web"
  type        = string
  default     = "10.145.60.0/27"
}

variable "subnet_private_apps_cidr" {
  description = "CIDR pour le sous-réseau privé applications"
  type        = string
  default     = "10.145.100.0/24"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Votre adresse IP pour l'accès SSH (format: x.x.x.x/32)"
  type        = string
}

variable "key_pair_name" {
  description = "Nom de la paire de clés SSH AWS existante"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Activer NAT Gateway pour les sous-réseaux privés (coûts supplémentaires)"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "training"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "Aws_infrastructure"
}

variable "common_tags" {
  description = "Tags communs à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Project     = "Aws_infrastructure"
    ManagedBy   = "Terraform"
    
  }
}
