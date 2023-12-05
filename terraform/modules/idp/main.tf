resource "confluent_identity_pool" "idp" {
  identity_provider {
    id = var.identity_provider_id
  }
  display_name   = var.identity_pool_name
  description    = format("Access to Kafka clusters to %s", var.identity_pool_name)
  identity_claim = "claims.sub"
  filter         = var.filter
}
