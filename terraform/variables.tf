variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_machine_type" {
  type    = string
  default = "e2-micro"
  validation {
    condition     = var.gcp_machine_type == "e2-micro"
    error_message = "Use e2-micro to stay in Always Free."
  }
}

variable "gcp_disk_gb" {
  type    = number
  default = 10
  validation {
    condition     = var.gcp_disk_gb <= 30
    error_message = "Keep disk <= 30GB to stay in free tier."
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_instance_type" {
  type    = string
  default = "t3.micro"
  validation {
    condition     = var.aws_instance_type == "t3.micro"
    error_message = "Use t3.micro to stay in free tier."
  }
}

variable "aws_ami" {
  description = "Amazon Linux 2 AMI (us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "aws_disk_gb" {
  type    = number
  default = 8
  validation {
    condition     = var.aws_disk_gb <= 30
    error_message = "Keep disk <= 30GB to stay in free tier."
  }
}

variable "aws_key_name" {
  description = "Existing AWS EC2 key pair to use"
  type        = string
  default     = "terraform-multicloud"
}
