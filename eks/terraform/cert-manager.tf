resource "helm_release" "cert-manager" {
    name = "cert-manager"

    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    namespace = "cert-manager"
    create_namespace = true
    version = "v1.16.2"

    set {
      name = "installCRDs" # cert-manager requires custom resources to automatically obtain and renew certificates
      value = "true"
    }

    depends_on = [ helm_release.external_nginx ]
}