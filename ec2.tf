# Security Group pour le serveur Web
resource "aws_security_group" "web_server" {
  name        = "Web-Server-SG"
  description = "Security group for web server - SSH and HTTP access"
  vpc_id      = aws_vpc.main.id

  # Règle entrante SSH - Depuis votre IP uniquement
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Règle entrante HTTP - Depuis Internet
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle sortante - Tout le trafic autorisé
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Web-Server-SG"
    Project = "Aws_infrastructure"
  }
}

# Recherche de l'AMI Amazon Linux 2023 la plus récente
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance EC2 - Serveur Web
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.dmz_web.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = var.key_pair_name

  # Script de bootstrap pour installer Apache
  user_data = <<-EOF
              #!/bin/bash
              # Mise à jour du système
              yum update -y
              
              # Installation d'Apache (httpd)
              yum install -y httpd
              
              # Démarrage du service Apache
              systemctl start httpd
              systemctl enable httpd
              
              # Création d'une page web personnalisée
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="fr">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>INF1097 - Serveur Web</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                      }
                      .container {
                          text-align: center;
                          background: rgba(255, 255, 255, 0.1);
                          padding: 50px;
                          border-radius: 20px;
                          backdrop-filter: blur(10px);
                      }
                      h1 {
                          font-size: 3em;
                          margin-bottom: 20px;
                      }
                      p {
                          font-size: 1.2em;
                      }
                      .info {
                          margin-top: 30px;
                          background: rgba(0, 0, 0, 0.2);
                          padding: 20px;
                          border-radius: 10px;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>Aws_infrastructure</h1>
                      <p>Serveur Web déployé avec Terraform Cloud</p>
                      <div class="info">
                          <p><strong>Projet:</strong> AWS Travail Training</p>
                          <p><strong>Instance ID:</strong> $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
                          <p><strong>Availability Zone:</strong> $(ec2-metadata --availability-zone | cut -d " " -f 2)</p>
                          <p><strong>Hostname:</strong> $(hostname)</p>
                      </div>
                  </div>
              </body>
              </html>
              HTML
              
              # Créer une page d'information système
              cat > /var/www/html/info.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>System Information</title>
              </head>
              <body>
                  <h1>System Information</h1>
                  <pre>
              $(cat /etc/os-release)
                  </pre>
                  <h2>Network Configuration</h2>
                  <pre>
              $(ip addr show)
                  </pre>
              </body>
              </html>
              HTML
              
              # Redémarrage d'Apache pour s'assurer que tout fonctionne
              systemctl restart httpd
              EOF

  tags = {
    Name        = "cloud-${var.student_number}-web-server"
    Environment = "Training"
    Project     = "Aws_infrastructure"
    Type        = "WebServer"
  }

  # Permet de recréer l'instance si le user_data change
  user_data_replace_on_change = true
}

# Elastic IP pour le serveur web (optionnel mais recommandé)
resource "aws_eip" "web_server" {
  instance = aws_instance.web_server.id
  domain   = "vpc"

  tags = {
    Name    = "cloud-${var.student_number}-web-eip"
    Project = "Aws_infrastructure"
  }

  depends_on = [aws_internet_gateway.main]
}
