output "resource_group_name" {
  description = "Nom du groupe de ressources"
  value       = azurerm_resource_group.main.name
}

output "log_analytics_workspace_id" {
  description = "ID de l'espace de travail Log Analytics"
  value       = azurerm_log_analytics_workspace.monitoring.id
}

output "log_analytics_workspace_name" {
  description = "Nom de l'espace de travail Log Analytics"
  value       = azurerm_log_analytics_workspace.monitoring.name
}

output "location" {
  description = "Localisation de l'infrastructure"
  value       = azurerm_resource_group.main.location
}
