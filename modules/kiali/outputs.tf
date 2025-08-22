output "name" {
  description = "Nome do release do Kiali"
  value       = helm_release.kiali.name
}

