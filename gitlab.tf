resource "random_password" "gitlab_root_user_personal_access_token" {
  length      = 20
  upper       = true
  min_upper   = 1
  lower       = true
  min_lower   = 1
  number      = true
  min_numeric = 1
  special     = false
}

// Idempotently create a PAT for the root user in GitLab
resource "null_resource" "set_gitlab_personal_access_token" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "kubectl exec -n gitlab -c task-runner $(kubectl get pod -n gitlab -l \"app=task-runner\" -o jsonpath='{.items[0].metadata.name}') -- gitlab-rails runner 'user = User.find_by_username(\"'\"$GITLAB_USER\"'\"); tokens = user.personal_access_tokens; token = tokens.find_by(name: \"'\"$TOKEN_NAME\"'\"); token = user.personal_access_tokens.create(scopes: [:api, :sudo], name: \"'\"$TOKEN_NAME\"'\") unless token.present?; token.set_token(\"'\"$TOKEN_VALUE\"'\"); token.save!'"
    environment = {
      GITLAB_USER = "root"
      KUBECONFIG  = abspath(local_file.kubeconfig.filename)
      TOKEN_NAME  = "terraform"
      TOKEN_VALUE = random_password.gitlab_root_user_personal_access_token.result
    }
  }
  depends_on = [
    null_resource.helmfile_deployments
  ]
}
