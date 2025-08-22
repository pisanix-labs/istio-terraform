variable "namespace" {
  description = "Namespace para a aplicação NGINX"
  type        = string
  default     = "demo"
}

variable "istio_namespace" {
  description = "Namespace onde o ingress gateway do Istio está"
  type        = string
  default     = "istio-system"
}

variable "replicas" {
  description = "Quantidade de réplicas do NGINX"
  type        = number
  default     = 1
}

variable "image" {
  description = "Imagem do NGINX"
  type        = string
  default     = "nginx:1.25-alpine"
}

variable "host" {
  description = "Host público (ex.: nginx.example.com). Se null, cria apenas recursos internos"
  type        = string
  default     = null
}

