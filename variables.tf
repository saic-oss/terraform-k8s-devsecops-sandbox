variable "kubeconfig_file_contents" {
  type        = string
  description = "Contents of kubeconfig file to use to connect to the cluster"
}

variable "gitlab_host_name" {
  type        = string
  description = "FQDN of desired GitLab endpoint e.g. gitlab.example.com. Max length 63 chars"
}

variable "registry_host_name" {
  type        = string
  description = "FQDN of desired GitLab Registry endpoint e.g. registry.gitlab.example.com. Max length 63 chars"
}

variable "minio_host_name" {
  type        = string
  description = "FQDN of desired GitLab Minio endpoint e.g. minio.gitlab.example.com. Max length 63 chars"
}

variable "jenkins_host_name" {
  type        = string
  description = "FQDN of desired Jenkins endpoint e.g. jenkins.example.com. Max length 63 chars"
}

variable "cluster_issuer" {
  type        = string
  description = "Name of Cert Manager ClusterIssuer to use"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of the Hosted Zone to create Route53 Records in"
}

variable "elb_dns_name" {
  type        = string
  description = "DNS name of the ELB that points at the cluster"
}

variable "elb_zone_id" {
  type        = string
  description = "Zone ID of the ELB that points at the cluster"
}

variable "jenkins_admin_email" {
  type        = string
  description = "email address of the Jenkins admin"
}
