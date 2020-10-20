# terraform-k8s-devsecops-sandbox

Terraform module for provisioning an ephemeral DevSecOps Sandbox to a Kubernetes cluster

## Introduction

### Purpose

The purpose of this module is to deploy a DevSecOps "sandbox" to a kubernetes cluster. It is intended to be a "turn-key" module, so it includes (almost) everything needed to have the sandbox tools up and running, including AWS resources like Route53 records.

### High-level design

#### Resources provisioned

- [x] Deploys GitLab using Helmfile
- [x] Applies GitLab configuration
- [x] Creates Route53 records for GitLab, Minio, and Registry
- [x] Configures the root password and provides it as an output
- [x] Creates a Personal Access Token for the root user and provides it as an output

## Usage

### Prerequisites

1. Terraform v0.13+ - Uses the new way to pull down 3rd party providers.
1. \*nix operating system - Windows not supported. If you need to use this on Windows you can run it from a Docker container.
1. Since this module uses a `local-exec`, the following tools also need to be installed on the machine using this module:
   1. [kubectl][kubectl]
   1. [helm][helm]
   1. [helmfile][helmfile]
   1. [helm-diff plugin][helm-diff]

### Instructions

#### Complete Example

The complete example requires 2 terraform applies due to dependency issues with the subnets being generated. For convenience, a Taskfile has been provided, to be used with [go-task][go-task]

```
task applyExample
task destroyExample
```

Here's a minimal example:

```hcl
provider "aws" {
  region = var.region
}

provider "local" {}

provider "null" {}

provider "random" {}

module "k8s-devsecops-sandbox" {
  source                   = "git::https://github.com/saic-oss/terraform-k8s-devsecops-sandbox.git?ref=tags/X.Y.Z"
  cluster_issuer           = "letsencrypt-${var.letsencrypt_environment}"
  kubeconfig_file_contents = module.rancher-k8s-cluster.cluster_kubeconfig
  gitlab_host_name         = "gl.${random_pet.default.id}.${var.hosted_zone_domain_name}"
  registry_host_name       = "reg.gl.${random_pet.default.id}.${var.hosted_zone_domain_name}"
  minio_host_name          = "min.gl.${random_pet.default.id}.${var.hosted_zone_domain_name}"
  hosted_zone_id           = var.hosted_zone_id
  elb_dns_name             = module.rancher-k8s-cluster.elb_dns_name
  elb_zone_id              = module.rancher-k8s-cluster.elb_zone_id
  depends_on = [
    module.rancher-k8s-cluster
  ]
  providers = {
    aws    = aws,
    local  = local,
    null   = null,
    random = random
  }
}
```

## Contributing

Contributors to this module should make themselves familiar with this section

### Prerequisites

- Terraform v0.13+
- [pre-commit][pre-commit]
- Pre-commit hook dependencies
  - nodejs (for the prettier hook)
  - [tflint][tflint]
  - [terraform-docs][terraform-docs]
  - [tfsec][tfsec]
- Run `pre-commit install` in root dir of repo (installs the pre-commit hooks so they run automatically when you try to do a git commit)
- Run `terraform init` in root dir of repo so the pre-commit hooks can work

### Versioning

This module will use SemVer, and will stay on v0.X for the foreseeable future

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0, < 0.14.0 |
| aws | >= 2.0.0, < 3.0.0 |
| local | >= 1.0.0, < 2.0.0 |
| null | >= 2.0.0, < 3.0.0 |
| random | >= 2.0.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0.0, < 3.0.0 |
| local | >= 1.0.0, < 2.0.0 |
| null | >= 2.0.0, < 3.0.0 |
| random | >= 2.0.0, < 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_issuer | Name of Cert Manager ClusterIssuer to use | `string` | n/a | yes |
| elb\_dns\_name | DNS name of the ELB that points at the cluster | `string` | n/a | yes |
| elb\_zone\_id | Zone ID of the ELB that points at the cluster | `string` | n/a | yes |
| gitlab\_host\_name | FQDN of desired GitLab endpoint e.g. gitlab.example.com. Max length 63 chars | `string` | n/a | yes |
| hosted\_zone\_id | ID of the Hosted Zone to create Route53 Records in | `string` | n/a | yes |
| kubeconfig\_file\_contents | Contents of kubeconfig file to use to connect to the cluster | `string` | n/a | yes |
| minio\_host\_name | FQDN of desired GitLab Minio endpoint e.g. minio.gitlab.example.com. Max length 63 chars | `string` | n/a | yes |
| registry\_host\_name | FQDN of desired GitLab Registry endpoint e.g. registry.gitlab.example.com. Max length 63 chars | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| gitlab\_endpoint | Endpoint for GitLab |
| gitlab\_minio\_endpoint | Endpoint for GitLab's Minio |
| gitlab\_registry\_endpoint | Endpoint for GitLab Registry |
| gitlab\_root\_password | Password for the 'root' user in GitLab |
| gitlab\_root\_user\_personal\_access\_token | Personal Access Token for the GitLab root user |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

[helm-operator]: https://github.com/fluxcd/helm-operator
[pre-commit]: https://pre-commit.com/
[tflint]: https://github.com/terraform-linters/tflint
[terraform-docs]: https://github.com/terraform-docs/terraform-docs
[tfsec]: https://github.com/liamg/tfsec
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[helm]: https://helm.sh/docs/intro/install/
[helmfile]: https://github.com/roboll/helmfile
[helm-diff]: https://github.com/databus23/helm-diff
[go-task]: https://taskfile.dev/#/
