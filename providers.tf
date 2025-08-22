variable "kubeconfig_path" {
  description = "Caminho para o kubeconfig do cluster Kubernetes"
  type        = string
  default     = "./scripts/kubeconfig-kind.yaml"
}

variable "kubeconfig_context" {
  description = "Contexto do kubeconfig a ser usado"
  type        = string
  default     = null
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path == null ? null : abspath(pathexpand(var.kubeconfig_path))
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path == null ? null : abspath(pathexpand(var.kubeconfig_path))
    config_context = var.kubeconfig_context
  }
}

provider "kubectl" {
  load_config_file       = true
  config_path            = var.kubeconfig_path == null ? null : abspath(pathexpand(var.kubeconfig_path))
  config_context         = var.kubeconfig_context
}
