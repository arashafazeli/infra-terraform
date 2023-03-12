provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}

data "kubectl_file_documents" "namespace" {
    content = file("../manifests/argocd/argocd_namespace.yaml")
}

data "kubectl_file_documents" "argocd" {
  content = file("../manifests/argocd/install_argocd.yaml")
}

resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace,
  ]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}