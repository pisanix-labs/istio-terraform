variable "namespace" {
  description = "Namespace onde o Prometheus será instalado"
  type        = string
  default     = "istio-system"
}

variable "chart_version" {
  description = "Versão do chart prometheus-community/prometheus. Deixe null para última disponível."
  type        = string
  default     = null
}

