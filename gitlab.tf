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

resource "null_resource" "add_jenkins_to_gitlab_applications" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "kubectl exec -n gitlab -c task-runner $(kubectl get pod -n gitlab -l \"app=task-runner\" -o jsonpath='{.items[0].metadata.name}') -- gitlab-rails runner 'Doorkeeper::Application.create(uid: \"'\"$JENKINS_ID\"'\", name: \"'\"jenkins\"'\", redirect_uri: \"'\"https://$JENKINS_HOST_NAME/securityRealm/finishLogin\"'\", trusted: true, confidential: true, scopes: [:api, :read_user, :read_api, :read_repository, :write_repository, :read_registry,  :write_registry], secret: \"'\"$JENKINS_SECRET\"'\")'"
    environment = {
      KUBECONFIG        = abspath(local_file.kubeconfig.filename)
      JENKINS_ID        = random_password.jenkins_id.result
      JENKINS_HOST_NAME = var.jenkins_host_name
      JENKINS_SECRET    = random_password.jenkins_secret.result
    }
  }
  depends_on = [
    null_resource.set_gitlab_personal_access_token
  ]
}

resource "null_resource" "set_api_token_for_jenkins" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "kubectl exec -n gitlab -c task-runner $(kubectl get pod -n gitlab -l \"app=task-runner\" -o jsonpath='{.items[0].metadata.name}') -- gitlab-rails runner 'user = User.find_by_username(\"'\"$GITLAB_USER\"'\"); tokens = user.personal_access_tokens; token = tokens.find_by(name: \"'\"$TOKEN_NAME\"'\"); token = user.personal_access_tokens.create(scopes: [:api], name: \"'\"$TOKEN_NAME\"'\") unless token.present?; token.set_token(\"'\"$TOKEN_VALUE\"'\"); token.save!'"
    environment = {
      GITLAB_USER = "root"
      KUBECONFIG  = abspath(local_file.kubeconfig.filename)
      TOKEN_NAME  = "jenkins"
      TOKEN_VALUE = random_password.gitlab_api_token.result
    }
  }
  depends_on = [
    null_resource.add_jenkins_to_gitlab_applications
  ]
}
