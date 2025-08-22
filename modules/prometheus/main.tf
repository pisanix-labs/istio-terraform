locals {
  repo = "https://prometheus-community.github.io/helm-charts"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = var.namespace
  repository = local.repo
  chart      = "prometheus"
  version    = var.chart_version

  create_namespace = false
  wait              = true
  timeout           = 900

  values = [
    yamlencode({
      alertmanager = { enabled = false }
      pushgateway  = { enabled = false }
      server = {
        global = {
          scrape_interval     = "15s"
          evaluation_interval = "15s"
        }
        persistentVolume = {
          enabled = false
        }
        service = {
          type = "ClusterIP"
          port = 80
        }
        resources = {
          limits = { cpu = "300m", memory = "1Gi" }
          requests = { cpu = "100m", memory = "512Mi" }
        }
      }
      serverFiles = {
        "prometheus.yml" = {
          scrape_configs = [
            {
              job_name            = "envoy-stats"
              metrics_path        = "/stats/prometheus"
              kubernetes_sd_configs = [{ role = "pod" }]
              relabel_configs = [
                { source_labels = ["__meta_kubernetes_pod_container_name"], action = "keep", regex = "istio-proxy" },
                { source_labels = ["__meta_kubernetes_pod_ip"], action = "replace", target_label = "__address__", regex = "(.+)", replacement = "$1:15090" },
                { action = "labelmap", regex = "__meta_kubernetes_pod_label_(.+)" },
                { source_labels = ["__meta_kubernetes_namespace"], action = "replace", target_label = "namespace" },
                { source_labels = ["__meta_kubernetes_pod_name"], action = "replace", target_label = "pod_name" }
              ]
            },
            {
              job_name = "istiod"
              kubernetes_sd_configs = [{ role = "endpoints" }]
              relabel_configs = [
                { source_labels = ["__meta_kubernetes_endpoints_name", "__meta_kubernetes_namespace"], action = "keep", regex = "istiod;${var.namespace}" }
              ]
            }
          ]
        }
      }
    })
  ]
}
