
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
    value = "e61b3523-2466-5dcf-b601-b4a3f1eb8780"
  }

  set_string {
    name  = "gremlin.secret.teamSecret"
    value = "21fa870a-5472-4aae-ba87-0a5472daae17
  }

  set_string {
    name  = "gremlin.secret.clusterID"
    value = module.eks.cluster_id
  }

  namespace = "${kubernetes_namespace.gremlin.metadata.0.name}"

}
