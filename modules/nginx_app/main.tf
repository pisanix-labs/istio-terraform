resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.image

          port {
            name           = "http"
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.apps]
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
  }
}

# Resources de rede do Istio (Gateway/VirtualService/DestinationRule)
resource "kubectl_manifest" "destination_rule" {
  yaml_body = yamlencode({
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "DestinationRule"
    metadata = {
      name      = "nginx-dr"
      namespace = var.namespace
    }
    spec = {
      host = "nginx.${var.namespace}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = { simple = "ROUND_ROBIN" }
      }
    }
  })

  depends_on = [kubernetes_service.nginx]
}

resource "kubectl_manifest" "virtual_service" {
  count = 1

  yaml_body = yamlencode({
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "nginx-vs"
      namespace = var.namespace
    }
    spec = {
      hosts    = [var.host != null ? var.host : "*"]
      gateways = ["${var.istio_namespace}/public-gw"]
      http = [{
        route = [{
          destination = {
            host = "nginx.${var.namespace}.svc.cluster.local"
            port = { number = 80 }
          }
        }]
      }]
    }
  })

  depends_on = [kubectl_manifest.destination_rule]
}
