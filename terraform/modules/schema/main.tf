data "confluent_schema_registry_cluster" "cluster" {
  environment {
    id = var.env_id
  }
}

resource "confluent_schema" "schema" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.cluster.rest_endpoint
  subject_name  = var.subject
  format        = var.format
  schema        = file(var.path)

  lifecycle {
    prevent_destroy = true
  }
}
