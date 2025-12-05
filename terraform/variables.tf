// ============================================
// VARIABLES
// ============================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-project"
}

variable "instance_type" {
  description = "EC2 size (t3.micro works in most regions)"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to deploy (max: available zones)"
  type        = number
  default     = 3
}

variable "key_name" {
  description = "SSH key name (create in AWS first)"
  type        = string
  default = "devops"
}

variable "allowed_cidr" {
  description = "Your IP address for SSH (e.g., ['1.2.3.4/32'])"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "private_key_path" {
  description = "Path to the SSH private key (.pem) for EC2 access"
  type        = string
  default     = "/Users/harshraj/Desktop/VS Code/Terraform/Devops-Project/devops.pem"
}