resource "kubernetes_namespace" "istio" {
  metadata {
    name = var.namespace
  }
}

locals {
  istio_repo = "https://istio-release.storage.googleapis.com/charts"
}

# Base CRDs
resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = var.namespace
  repository = local.istio_repo
  chart      = "base"
  version    = var.istio_version

  create_namespace = false
  wait              = true
  timeout           = 600

  depends_on = [kubernetes_namespace.istio]
}

# Istiod (control plane)
resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = var.namespace
  repository = local.istio_repo
  chart      = "istiod"
  version    = var.istio_version

  values = [
    yamlencode({
      pilot = {
        autoscaleEnabled = true
      }
    })
  ]

  wait    = true
  timeout = 600
  depends_on = [helm_release.istio_base]
}

# Istio Ingress Gateway
resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = var.namespace
  repository = local.istio_repo
  chart      = "gateway"
  version    = var.istio_version

  values = [
    yamlencode({
      service = {
        type = var.ingress_service_type
      }
      labels = {
        istio = "ingressgateway"
      }
    })
  ]

  wait    = false
  timeout = 300
  depends_on = [helm_release.istiod]
}

resource "kubectl_manifest" "public_gateway" {
  yaml_body = yamlencode({
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "public-gw"
      namespace = var.namespace
    }
    spec = {
      selector = { istio = "ingressgateway" }
      servers = [{
        port = { number = 80, name = "http", protocol = "HTTP" }
        hosts = var.gateway_hosts
      }]
    }
  })

  depends_on = [helm_release.istio_ingress]
}

data "kubernetes_service" "ingress_svc" {
  metadata {
    name      = helm_release.istio_ingress.name
    namespace = var.namespace
  }

  depends_on = [helm_release.istio_ingress]
}
