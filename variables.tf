variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
  default     = "rg-monitoring"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "East US"
}
