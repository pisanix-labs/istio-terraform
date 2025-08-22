locals {
  kiali_repo = "https://kiali.org/helm-charts"
}

resource "helm_release" "kiali" {
  name       = "kiali"
  namespace  = var.namespace
  repository = local.kiali_repo
  chart      = "kiali-server"
  version    = var.chart_version

  create_namespace = false

  values = [
    yamlencode({
      auth = {
        strategy = "anonymous"
      }
      deployment = {
        accessible_namespaces = ["**"]
      }
      external_services = {
        istio = {
          root_namespace = var.namespace
        }
        prometheus = var.prometheus_url == null ? null : {
          url = var.prometheus_url
        }
        grafana = {
          enabled = false
        }
      }
    })
  ]
}

resource "kubectl_manifest" "kiali_vs" {
  count = var.expose_via_istio ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "kiali-vs"
      namespace = var.namespace
    }
    spec = {
      hosts    = [var.host != null ? var.host : "*"]
      gateways = ["${var.istio_namespace}/public-gw"]
      http = [{
        route = [{
          destination = {
            host = "kiali"
            port = { number = 20001 }
          }
        }]
      }]
    }
  })

  depends_on = [helm_release.kiali]
}
