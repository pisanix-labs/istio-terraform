output "service" {
  description = "Serviço Kubernetes do NGINX"
  value = {
    name      = kubernetes_service.nginx.metadata[0].name
    namespace = kubernetes_service.nginx.metadata[0].namespace
  }
}

