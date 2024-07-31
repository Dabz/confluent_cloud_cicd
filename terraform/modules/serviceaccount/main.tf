resource "confluent_service_account" "sa" {
  display_name = var.serviceaccount.name
  description  = var.serviceaccount.description
}
