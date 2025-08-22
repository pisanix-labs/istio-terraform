variable "namespace" {
  description = "Namespace do Istio"
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  description = "Versão do Istio/Charts (ex.: 1.12.2)"
  type        = string
}

variable "ingress_service_type" {
  description = "Tipo do Service do Istio Ingress (LoadBalancer ou NodePort)"
  type        = string
  default     = "LoadBalancer"
}

variable "gateway_hosts" {
  description = "Lista de hosts aceitos pelo Gateway público do Istio"
  type        = list(string)
  default     = ["*"]
}
