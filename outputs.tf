output "gitlab_root_password" {
  description = "Password for the 'root' user in GitLab"
  value       = random_password.gitlab_initial_root_password.result
  sensitive   = true
}

output "gitlab_endpoint" {
  description = "Endpoint for GitLab"
  value       = "https://${var.gitlab_host_name}"
}

output "gitlab_registry_endpoint" {
  description = "Endpoint for GitLab Registry"
  value       = "https://${var.registry_host_name}"
}

output "gitlab_minio_endpoint" {
  description = "Endpoint for GitLab's Minio"
  value       = "https://${var.minio_host_name}"
}

output "gitlab_root_user_personal_access_token" {
  description = "Personal Access Token for the GitLab root user"
  value       = random_password.gitlab_root_user_personal_access_token.result
  sensitive   = true
}
