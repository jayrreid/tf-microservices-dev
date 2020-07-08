
resource "kubernetes_namespace" "gremlin" {
  metadata {
    name = "gremlin"
  }
}


resource "helm_release" "gremlin" {
  name = "gremlin"
  repository = "https://helm.gremlin.com/"
  chart = "gremlin"

  set {
    name  = "gremlin.secret.managed"
    value = "true"
  }

  set {
    name  = "gremlin.secret.type"
    value = "secret"
  }

  set_string {
    name  = "gremlin.secret.teamID"
    value = var.gremlin_secret_teamID
  }

  set_string {
    name  = "gremlin.secret.teamSecret"
    value = var.gremlin_secret_teamSecret
  }

  set_string {
    name  = "gremlin.secret.clusterID"
    value = module.eks.cluster_id
  }

  namespace = "${kubernetes_namespace.gremlin.metadata.0.name}"

}
