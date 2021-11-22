variable "resource_group_name" {
  type        = string
  description = "Target resource group to deploy the test stack"
}

variable "admin_username" {
  type        = string
  description = "VM admin username"
  default     = "vmadmin"
}

variable "vm_sku" {
  type        = string
  description = "VM sku"
  default     = "Standard_D2_v4"
}

variable "vmss_size" {
  type        = number
  description = "VM scale set size"
  default     = 3
}

variable "ubuntu_sku" {
  type        = string
  description = "Ubuntu image version"
  default     = "20_04-lts-gen2"
}