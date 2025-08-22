output "istio_ingress_gateway" {
  description = "Serviço do Istio Ingress Gateway"
  value       = module.istio.ingress_service
}

output "nginx_url" {
  description = "URL pública do NGINX (se domain_base informado)"
  value       = var.domain_base == null ? null : "http://${local.nginx_host}"
}

output "kiali_url" {
  description = "URL pública do Kiali (se exposto e domain_base informado)"
  value       = var.domain_base == null || !var.kiali_expose ? null : "http://${local.kiali_host}"
}

