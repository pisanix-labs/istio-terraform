variable "istio_version" {
  description = "Versão do Istio a ser instalada (ex.: 1.12.2)"
  type        = string
  default     = "1.20.3"
}

variable "domain_base" {
  description = "Domínio base para exposição pública (ex.: example.com)"
  type        = string
  default     = null
}

variable "kiali_expose" {
  description = "Se true, expõe o Kiali via Istio Gateway/VirtualService"
  type        = bool
  default     = true
}

variable "kiali_chart_version" {
  description = "Versão do chart do Kiali compatível com o Istio (ex.: 1.76.0 para Istio 1.20.x)"
  type        = string
  default     = "1.76.0"
}

variable "istio_ingress_service_type" {
  description = "Tipo do Service do Istio Ingress (LoadBalancer ou NodePort)"
  type        = string
  default     = "NodePort"
}

variable "namespaces" {
  description = "Nomes dos namespaces usados no projeto"
  type = object({
    istio = string
    apps  = string
  })
  default = {
    istio = "istio-system"
    apps  = "demo"
  }
}
