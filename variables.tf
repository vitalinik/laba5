variable "aws_region" {
  description = "AWS region where region-specific resources are created."
  type        = string
}

variable "project_id" {
  description = "Project identifier used for required tags."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used to generate security group names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the pre-created VPC where security groups are created."
  type        = string
}

variable "public_instance_id" {
  description = "ID of the pre-created public EC2 instance."
  type        = string
}

variable "private_instance_id" {
  description = "ID of the pre-created private EC2 instance."
  type        = string
}

variable "allowed_ip_range" {
  description = "List of CIDR ranges allowed to access public SSH, HTTP, and ICMP."
  type        = list(string)
}
