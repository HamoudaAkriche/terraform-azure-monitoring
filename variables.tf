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

variable "admin_username" {
  description = "Nom d'utilisateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Mot de passe de la VM (attention à la sécurité)"
  type        = string
  sensitive   = true
  default     = "Admin@1234" # je vais changer le mdp !!!
}