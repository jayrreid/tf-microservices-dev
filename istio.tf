resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = ">= 1.11.1"
}

provider "helm" {
  version = "v1.1.1"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

resource "helm_release" "istio_init" {

  name       = "istio-init"
  repository = "https://storage.googleapis.com/istio-release/releases/1.3.2/charts/"
  chart      = "istio-init"
  version    = "1.3.2"
  namespace  = "${kubernetes_namespace.istio_system.metadata.0.name}"

  # give istio_init time to set up
   provisioner "local-exec" {
     command = "sleep 60"
   }
}


/* even though depends_on is configured, this will fail because the above CRDs
* have yet to propagate to the api server. the only solution thus far is to introduce
* a delay within the terraform config. */
resource "helm_release" "istio" {
  depends_on = ["helm_release.istio_init"]
  name       = "istio"
  repository = "https://storage.googleapis.com/istio-release/releases/1.3.2/charts/"
  version    = "1.3.2"
  chart      = "istio"
  namespace  = "kubernetes_namespace.istio_system.metadata.0.name"

  wait       = true
}
