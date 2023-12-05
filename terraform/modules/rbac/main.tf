data "confluent_identity_pool" "idp" {
  display_name = var.identity_pool_name
  identity_provider {
    id = var.identity_provider_id
  }
}

resource "confluent_role_binding" "rb" {
  principal   = "User:${data.confluent_identity_pool.idp.id}"
  role_name   = var.role
  crn_pattern = var.crn
}
