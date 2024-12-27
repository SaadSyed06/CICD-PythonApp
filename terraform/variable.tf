# Define variables for reuse across environments

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "ssh_public_key_path" {
  description = "The path to the SSH public key"
  type        = string
}