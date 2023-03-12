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

data "kubectl_file_documents" "argocd_image_updater" {
  content = file("../manifests/argocd/install_argocd_image_updater.yaml")
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

resource "kubectl_manifest" "argocd_image_updater" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  count              = length(data.kubectl_file_documents.argocd_image_updater.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd_image_updater.documents, count.index)
  override_namespace = "argocd"
}

# provider "helm" {
#   kubernetes {
#     host = module.gke_auth.host
#     cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
#   }
# }

# resource "helm_release" "argocd" {
#     depends_on = [
#     kubectl_manifest.namespace,
#   ]
#   name  = "argocd"

#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   version          = "4.9.7"
#   create_namespace = true

#   set {
#     name  = "service.argocd-server.type"
#     value = "NodePort"
#   }
# }