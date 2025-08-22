Projeto Terraform: Istio, Kiali e NGINX

Resumo
- Instala o Istio (base, istiod e ingress gateway) via Helm.
- Instala o Kiali (versão fixada, compatível com a do Istio) e integra com o Istio.
- Instala o Prometheus (prometheus-community/prometheus) com scrape mínimo para Istio e aponta o Kiali para ele.
- Implanta NGINX de exemplo e expõe rota pública via Istio (Gateway/VirtualService).

Pré‑requisitos
- Terraform >= 1.5
- Acesso a um cluster Kubernetes e `kubeconfig` configurado.
- Para ambientes cloud, DNS apontado para o IP/hostname do LoadBalancer do Istio Ingress Gateway (quando usar `domain_base`). Em ambiente local (kind), o projeto usa NodePort por padrão.

Observação sobre versões
- A variável `istio_version` está padrão para `1.20.3`, compatível com clusters Kubernetes recentes (≥1.25). Se precisar de uma versão específica, ajuste `-var istio_version=...`. Versões antigas como `1.12.x` podem falhar em clusters novos por usarem APIs removidas.
- O Kiali está fixado por padrão em `kiali_chart_version = 1.76.0`, compatível com Istio 1.20.x (onde os CRDs ainda são `v1beta1`). Versões mais novas do Kiali esperam CRDs `v1` e podem causar erros como "no matches for kind ... in version networking.istio.io/v1". Ajuste esta variável se mudar o `istio_version`.

Estrutura
- `modules/istio`: instala CRDs, control plane, ingress gateway e um Gateway público compartilhado (`public-gw`).
- `modules/kiali`: instala Kiali e cria VirtualService anexado ao `public-gw`.
- `modules/nginx_app`: cria namespace com injeção do sidecar, deploy de NGINX e VirtualService anexado ao `public-gw`.

Variáveis principais
- `kubeconfig_path`: caminho do kubeconfig (padrão: `~/.kube/config`).
- `kubeconfig_context`: contexto do kubeconfig (opcional).
- `istio_version`: versão do Istio/Charts (ex.: `1.20.3`).
- `domain_base`: domínio base para hosts públicos (ex.: `example.com`).
- `kiali_expose`: se `true`, expõe o Kiali via Istio.
- `kiali_chart_version`: versão do chart do Kiali compatível com o Istio (padrão: `1.76.0`).
- `istio_ingress_service_type`: tipo do Service do ingress (`NodePort` por padrão para kind/local, mude para `LoadBalancer` em cloud).
- `namespaces`: namespaces usados (`istio-system` e `demo` por padrão).

Como usar
1) Ajuste variáveis em `terraform.tfvars` (exemplo abaixo) ou passe via `-var`.

Exemplo `terraform.tfvars` (local/kind):
kubeconfig_path              = "./scripts/kubeconfig-kind.yaml"
istio_version                = "1.20.3"
istio_ingress_service_type   = "NodePort"
kiali_expose                 = true
kiali_chart_version          = "1.76.0"
namespaces = {
  istio = "istio-system"
  apps  = "demo"
}

Para cloud, adicione `domain_base = "example.com"` e troque `istio_ingress_service_type = "LoadBalancer"`.

2) Inicialize e aplique:
terraform init
terraform plan
terraform apply

3) Descobrir o endpoint do Ingress do Istio:
kubectl -n istio-system get svc --kubeconfig=./scripts/kubeconfig-kind.yaml istio-ingress -o wide

4) DNS: crie os registros `A`/`CNAME` para `nginx.${domain_base}` e `kiali.${domain_base}` apontando para o IP/hostname do LoadBalancer do passo anterior.

5) Port forward para acesso via WSL2
`
kubectl -n istio-system port-forward svc/kiali 20001:20001 --kubeconfig=./scripts/kubeconfig-kind.yaml
`
> acesso: http://localhost:20001


Acesso
- Local (kind):
  - Descubra NodePort: `kubectl -n istio-system get svc --kubeconfig=./scripts/kubeconfig-kind.yaml istio-ingress`
  - Acesse NGINX via `http://NODE-IP:NODEPORT`
  - Acesse Kiali via `http://NODE-IP:NODEPORT/kiali`
- Cloud (com `domain_base`):
  - NGINX: `http://nginx.${domain_base}`
  - Kiali:  `http://kiali.${domain_base}`

Notas
- O Kiali está configurado com `auth.strategy = anonymous` apenas para testes. Ajuste para o método de autenticação desejado em produção.
- Os CRDs do Istio são instalados via chart `base`. Certifique-se de usar versões de charts compatíveis entre si.
- Se seu provedor de cloud não suporta `LoadBalancer`, altere `modules/istio/main.tf` para usar tipo `NodePort` e exponha externamente por outro meio.
- O Prometheus é instalado no namespace do Istio e o Kiali é configurado para usar `http://prometheus-server.${namespace}.svc.cluster.local`. Há um scrape config mínimo para sidecars Envoy (porta 15090) e para o `istiod`.
- Se já existir um Prometheus externo, remova o módulo `prometheus` e passe `prometheus_url` ao módulo do Kiali conforme necessário.
