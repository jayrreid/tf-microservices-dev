
resource "kubernetes_namespace" "gremlin" {
  metadata {
    name = "gremlin"
  }
}


resource "helm_release" "gremlin" {

  name       = "gremlin"
  repository = "https://helm.gremlin.com/"
  chart      = "gremlin"
  gremlin.secret.managed    = "true"
  gremlin.secret.type       = "secret"
  gremlin.secret.teamID     = "e61b3523-2466-5dcf-b601-b4a3f1eb8780"
  gremlin.secret.clusterID  = module.eks.cluster_id
  gremlin.secret.teamSecret = "21fa870a-5472-4aae-ba87-0a5472daae17"

  namespace  = "${kubernetes_namespace.gremlin.metadata.0.name}"

}
