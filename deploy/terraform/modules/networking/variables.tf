variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "Subnet prefixes"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}
