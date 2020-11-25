resource "local_file" "kubeconfig" {
  filename = "${path.module}/tmp/kubeconfig.yaml"
  content  = var.kubeconfig_file_contents
}

resource "random_password" "postgresql_postgres_password" {
  length           = 16
  upper            = true
  min_upper        = 1
  lower            = true
  min_lower        = 1
  number           = true
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "_%@"
}

resource "random_password" "gitlab_initial_root_password" {
  length           = 16
  upper            = true
  min_upper        = 1
  lower            = true
  min_lower        = 1
  number           = true
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "_%@"
}

resource "random_password" "gitlab_api_token" {
  length      = 20
  upper       = true
  min_upper   = 1
  lower       = true
  min_lower   = 1
  number      = true
  min_numeric = 1
  special     = false
}

resource "random_password" "jenkins_initial_admin_password" {
  length           = 16
  upper            = true
  min_upper        = 1
  lower            = true
  min_lower        = 1
  number           = true
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "_%@"
}

resource "random_password" "jenkins_id" {
  length      = 20
  upper       = true
  min_upper   = 1
  lower       = true
  min_lower   = 1
  number      = true
  min_numeric = 1
  special     = false
}

resource "random_password" "jenkins_secret" {
  length      = 20
  upper       = true
  min_upper   = 1
  lower       = true
  min_lower   = 1
  number      = true
  min_numeric = 1
  special     = false
}

resource "null_resource" "helmfile_deployments" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "helmfile -f ${path.module}/helmfiles/helmfile.yaml apply"
    environment = {
      CLUSTER_ISSUER                             = var.cluster_issuer
      GITLAB_API_TOKEN                           = random_password.gitlab_api_token.result
      GITLAB_GITLAB_HOST_NAME                    = var.gitlab_host_name
      GITLAB_REGISTRY_HOST_NAME                  = var.registry_host_name
      GITLAB_MINIO_HOST_NAME                     = var.minio_host_name
      GITLAB_INITIAL_ROOT_PASSWORD_SECRET_NAME   = "gitlab-initial-root-password"
      GITLAB_INITIAL_ROOT_PASSWORD_SECRET_KEY    = "password"
      GITLAB_INITIAL_ROOT_PASSWORD               = random_password.gitlab_initial_root_password.result
      KUBECONFIG                                 = abspath(local_file.kubeconfig.filename)
      POSTGRESQL_FULLNAME_OVERRIDE               = "postgresql"
      POSTGRESQL_POSTGRES_PASSWORD               = random_password.postgresql_postgres_password.result
      POSTGRESQL_DATABASE_NAME                   = "gitlabhq_production"
      JENKINS_HOST_NAME                          = var.jenkins_host_name
      JENKINS_ADMIN_EMAIL                        = var.jenkins_admin_email
      JENKINS_INITIAL_ADMIN_CREDS_SECRET_NAME    = "jenkins-initial-admin-creds"
      JENKINS_INITIAL_ADMIN_CREDS_USER_KEY       = "jenkins-admin-user"
      JENKINS_INITIAL_ADMIN_CREDS_USER_VALUE     = "admin"
      JENKINS_INITIAL_ADMIN_CREDS_PASSWORD_KEY   = "jenkins-admin-password"
      JENKINS_INITIAL_ADMIN_CREDS_PASSWORD_VALUE = random_password.jenkins_initial_admin_password.result
      JENKINS_SECRET                             = random_password.jenkins_secret.result
      JENKINS_ID                                 = random_password.jenkins_id.result
    }
  }
  depends_on = [
    aws_route53_record.gitlab,
    aws_route53_record.jenkins,
    aws_route53_record.registry,
    aws_route53_record.minio
  ]
}
