variable "namespace" {
  description = "Namespace onde o Kiali será instalado (normalmente o mesmo do Istio)"
  type        = string
  default     = "istio-system"
}

variable "istio_namespace" {
  description = "Namespace do Istio (para referenciar o Gateway público)"
  type        = string
  default     = "istio-system"
}

variable "chart_version" {
  description = "Versão do chart do Kiali (ex.: 1.76.0). Escolha uma versão compatível com sua versão do Istio."
  type        = string
  default     = "1.76.0"
}

variable "expose_via_istio" {
  description = "Se true, cria Gateway/VirtualService do Istio para o Kiali"
  type        = bool
  default     = true
}

variable "host" {
  description = "Host público para o Kiali (ex.: kiali.example.com)"
  type        = string
  default     = null
}

variable "prometheus_url" {
  description = "URL do Prometheus acessível pelo Kiali (ex.: http://prometheus-server.istio-system.svc.cluster.local)"
  type        = string
  default     = null
}
