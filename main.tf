locals {
  nginx_host    = var.domain_base == null ? null : "nginx.${var.domain_base}"
  kiali_host    = var.domain_base == null ? null : "kiali.${var.domain_base}"
  gateway_hosts = var.domain_base == null ? ["*"] : [local.nginx_host, local.kiali_host]
}

module "istio" {
  source         = "./modules/istio"
  namespace      = var.namespaces.istio
  istio_version  = var.istio_version
  ingress_service_type = var.istio_ingress_service_type
  gateway_hosts        = local.gateway_hosts
}

module "kiali" {
  source             = "./modules/kiali"
  namespace          = var.namespaces.istio
  istio_namespace    = var.namespaces.istio
  expose_via_istio   = var.kiali_expose
  host               = local.kiali_host
  chart_version      = var.kiali_chart_version
  prometheus_url     = "http://prometheus-server.${var.namespaces.istio}.svc.cluster.local"

  depends_on = [module.istio]
}

module "nginx_app" {
  source          = "./modules/nginx_app"
  namespace       = var.namespaces.apps
  istio_namespace = var.namespaces.istio
  host            = local.nginx_host

  depends_on = [module.istio]
}

# Observability: Prometheus para métricas do Istio/Kiali
module "prometheus" {
  source    = "./modules/prometheus"
  namespace = var.namespaces.istio

  depends_on = [module.istio]
}
