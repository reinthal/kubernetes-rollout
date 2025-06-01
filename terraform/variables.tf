# =============================================================================
# AUTHENTICATION & SECURITY
# =============================================================================

variable "hetzner_api_key" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDG2HQMrYddPMA9CnLIPH4b0Iasg5LkQDW/BNR8wGsbbZ9++v41Tggri5Yq6V5EBcpFVLdEcRgPbRqPk10QLAVXilDBqz6sMUrLyUt5KXhG37X9x4ro0F1/87I0CY3OrDnfm09uclc4tH5gJyeLfiHGOUKZx4malacdWQFCdN7JBHqG0QE++WTilOFerlfQMJULnt75u3zJE5f+IjG7xdjSbx3tr2F7MYMVS21LY1S5UIldl7JHxWz4OaT9CD0+n2t+718tUT7rsLKG34V5yZwMbwOU3D0sjR++umO0hsT4yFRK4/U9Wj17QoLVub14FFUuQDVStuNmr97IgDnn/cSRgStdikksbrQQB0eFmhQf4+hp1uBoTGKE/hgEwG2Bio+xQjCDwLrIgWAUvWiJ7rIbrib3DtchHrK5/MHa09Xfkv692AuhIfmLdxL1FdXCosRf2NOZJ1iQNybqhMgyaifJA7CyIf3/ty0SQMM+Mwt60FDpzGFHrxCx1by7u/gUKV1L97RMekp4pM2Z+Q9fi/ySOurYXW0AsAr1kkCicF4y2MEX/qL1Tse+6ywgACucLGnP/cEvn5YYu8KOcQwZDiKr2YscWH3XOZIE5rqKnXxembEdDh1vNHjL9RQotA7EdZ5C0WbtqYwgVHH1CwlpHtTo1gVN18YIyKl4ZL1pl6DGOw== openpgp:0x9A29FF08"
}

# =============================================================================
# CLUSTER CONFIGURATION
# =============================================================================

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "talos-hcloud-cluster"
}

variable "talos_version_contract" {
  description = "Talos API version to use for the cluster, if not set the version shipped with the talos sdk version will be used"
  type        = string
  default     = "v1.6"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster, if not set the k8s version shipped with the talos sdk version will be used"
  type        = string
  default     = null
}

# =============================================================================
# INFRASTRUCTURE LOCATION
# =============================================================================

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1" # Nuremberg, Germany
}

variable "network_zone" {
  description = "Network zone"
  type        = string
  default     = "eu-central"
}

# =============================================================================
# SERVER CONFIGURATION
# =============================================================================

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx22" # 2 vCPU, 4 GB RAM - adjust as needed
}

variable "image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-22.04" # Base image for Talos/Omni
}

variable "snapshot_id" {
  description = "ID of the Hetzner snapshot to use"
  type        = string
  default     = "241639771"
}

# =============================================================================
# CONTROL PLANE CONFIGURATION
# =============================================================================

variable "controlplane_type" {
  description = "Server type for control plane nodes"
  type        = string
  default     = "cx32"
}

variable "controlplane_ip" {
  description = "Private IP address for control plane"
  type        = string
  default     = "10.0.0.3"
}

# =============================================================================
# WORKER CONFIGURATION
# =============================================================================

variable "workers" {
  description = "Worker definition"
}

variable "worker_extra_volume_size" {
  description = "Size of SSD volume to attach to workers"
  type        = number
  default     = 10
}

# =============================================================================
# NETWORKING
# =============================================================================

variable "private_network_name" {
  description = "Name of the private network"
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

# =============================================================================
# LOAD BALANCER
# =============================================================================

variable "load_balancer_type" {
  description = "Type of load balancer to create"
  type        = string
  default     = "lb11"
}

# =============================================================================
# TAILSCALE CONFIGURATION
# =============================================================================

variable "tailscale_authkey" {
  description = "Tailscale authentication key for auto-joining nodes to your network"
  type        = string
  sensitive   = true
}

variable "tailscale_extra_args" {
  description = "Additional arguments for Tailscale startup"
  type        = string
  default     = "--ssh"  # Enable SSH server by default
} 