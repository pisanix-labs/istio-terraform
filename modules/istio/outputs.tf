output "ingress_service" {
  description = "Serviço do Istio Ingress Gateway"
  value = {
    name      = helm_release.istio_ingress.name
    namespace = var.namespace
    type      = try(data.kubernetes_service.ingress_svc.spec[0].type, null)
    hostname  = try(data.kubernetes_service.ingress_svc.status[0].load_balancer[0].ingress[0].hostname, null)
    ip        = try(data.kubernetes_service.ingress_svc.status[0].load_balancer[0].ingress[0].ip, null)
  }
}

