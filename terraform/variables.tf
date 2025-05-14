variable "hetzner_api_key" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx21" # 2 vCPU, 4 GB RAM - adjust as needed
}

variable "image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-22.04" # Base image for Talos/Omni
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1" # Nuremberg, Germany
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
} 