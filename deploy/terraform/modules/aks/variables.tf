variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for AKS"
  type        = string
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling"
  type        = bool
}

variable "min_count" {
  description = "Minimum node count"
  type        = number
}

variable "max_count" {
  description = "Maximum node count"
  type        = number
}

variable "max_pods" {
  description = "Maximum pods per node"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}
