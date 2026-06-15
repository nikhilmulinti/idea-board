variable "project_id" {
  description = "Name of the GCP Project"
  type        = string
}

variable "enable_gcs_s3_compat" {
  description = "Enable GCS S3-compatible access with HMAC keys"
  type        = bool
  default     = false
}

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket for S3-compatible access (optional)"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "env_name" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "private_subnet_cidr" {
  default     = "10.10.0.0/24"
  description = "cidr_range for private subnet"
}

variable "public_subnet_cidr" {
  default     = "10.10.64.0/19"
  description = "cidr_range for public subnet"
}

variable "gke_version" {
  default = "1.32.2-gke.1182003"
}

variable "node_machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-medium"
}

variable "desired_node_count" {
  description = "Desired number of GKE nodes"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of GKE nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of GKE nodes"
  type        = number
  default     = 3
}

variable "node_disk_size_gb" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 30
}

variable "db_instance_tier" {
  default = "db-f1-micro"
}

variable "db_disk_size_gb" {
  default = "10"
}

variable "db_max_connections" {
  default = "100"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ideaboard"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "ideaboard"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "force_peering_cleanup" {
  description = "Force cleanup of VPC peering on destroy"
  type        = bool
  default     = false
}