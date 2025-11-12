data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-web"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_instance" "gcp_web" {
  name         = "gcp-web"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = var.gcp_disk_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network = data.google_compute_network.default.name
    access_config {}
  }

  metadata = {
    user-data = <<-EOT
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - echo "Hello from GCP (multicloud-tf)" > /var/www/html/index.nginx-debian.html
  - systemctl enable nginx
  - systemctl restart nginx
EOT
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_web" {
  name        = "allow-web"
  description = "Allow HTTP + SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "aws_web" {
  ami                         = var.aws_ami
  instance_type               = var.aws_instance_type
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    echo "Hello from AWS (multicloud-tf)" > /usr/share/nginx/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "aws-web"
  }

  depends_on = [
    aws_security_group.allow_web
  ]
}