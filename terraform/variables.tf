# Hetzner Cloud Provider
variable "hetzner_api_key" {
  description = "Hetzner Cloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Hetzner Cloud location for resources"
  type        = string
  default     = "fsn1"
}

variable "network_zone" {
  description = "Hetzner Cloud network zone for load balancer"
  type        = string
  default     = "eu-central"
}

# Talos Configuration
variable "image_id" {
  description = "Hetzner snapshot ID for custom Talos OS image"
  type        = string
  default     = "241897526"
}

variable "cluster_name" {
  description = "Name for the Talos cluster"
  type        = string
  default     = "talos-hloud-cluster"
}

variable "talos_version_contract" {
  description = "Talos API version to use for the cluster"
  type        = string
  default     = "v1.6"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
  type        = string
  default     = null
}

# Control Plane Configuration
variable "controlplane_type" {
  description = "Hetzner server type for control plane nodes"
  type        = string
  default     = "cx32"
}

variable "controlplane_ip" {
  description = "Private IP address for the control plane node"
  type        = string
  default     = "10.0.0.3"
}

# Network Configuration
variable "private_network_name" {
  description = "Name for the private network"
  type        = string
  default     = "talos-network"
}

variable "private_network_ip_range" {
  description = "IP range for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_network_subnet_range" {
  description = "IP range for the private network subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# Load Balancer Configuration
variable "load_balancer_type" {
  description = "Hetzner load balancer type"
  type        = string
  default     = "lb11"
}

# Worker Node Configuration
variable "workers" {
  description = "Map of worker node configurations"
  type = map(object({
    server_type = string
    name        = string
    location    = string
    ip          = string
    labels      = map(string)
    taints      = list(string)
  }))
}

variable "worker_extra_volume_size" {
  description = "Size in GB of additional SSD volume to attach to worker nodes"
  type        = number
  default     = 10

  validation {
    condition     = var.worker_extra_volume_size >= 10
    error_message = "Worker extra volume size must be at least 10 GB."
  }
}
