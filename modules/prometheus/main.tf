locals {
  repo = "https://prometheus-community.github.io/helm-charts"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = var.namespace
  repository = local.repo
  chart      = "prometheus"
  version    = var.chart_version

  values = [
    templatefile("${path.module}/values.tftpl", {
      namespace = var.namespace
    })
  ]
}
