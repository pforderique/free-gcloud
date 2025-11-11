variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "region" {
  description = "Free-tier region: us-east1, us-central1, or us-west1"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "Zone within the region"
  type        = string
  default     = "us-east1-b"
}

variable "nat_ip" {
  description = "Static external IP address for the VM"
  type        = string
  default     = ""  # e.g. "35.123.45.67"
}

variable "ssh_source_cidr" {
  description = "CIDR range allowed for SSH"
  type        = string
  # allows SSH from anywhere, ideally this should be restricted to a specific IP
  default     = "0.0.0.0/0"
}
