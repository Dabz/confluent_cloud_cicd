terraform {
}

provider "confluent" {
  kafka_id         = var.kafka_id
  cloud_api_key    = var.cloud_api_key
  cloud_api_secret = var.cloud_api_secret
}

##
## FETCHING DATA
##

data "confluent_organization" "org" {
}

data "confluent_environment" "env" {
  id = var.env_id
}

data "confluent_schema_registry_region" "cluster" {
  cloud   = var.schema_registry_cloud
  region  = var.schema_registry_region
  package = "ADVANCED"
}

data "confluent_schema_registry_cluster" "cluster" {
  display_name = "Stream Governance Package"
  environment {
    id = var.env_id
  }
}

data "confluent_kafka_cluster" "cluster" {
  id = var.kafka_id
  environment {
    id = var.env_id
  }
}

locals {
  topics = jsondecode(file("../env/dev/${var.project}/${var.project_env}/topics.json"))
  rbacs  = jsondecode(file("../env/dev/${var.project}/${var.project_env}/rbacs.json"))
  idp    = jsondecode(file("../env/dev/${var.project}/${var.project_env}/idp.json"))
}

##
## CREATING IDP
##

module "idp" {
  source               = "./modules/idp"
  identity_pool_name   = var.project
  identity_provider_id = var.identity_provider_id
  filter               = local.idp.filter
}


##
## CREATING TOPICS
##

module "topic" {
  for_each = { for topic in local.topics.topics : topic.name => topic }
  source   = "./modules/topic"
  env_id   = data.confluent_environment.env.id
  kafka_id = data.confluent_kafka_cluster.cluster.id
  topic    = each.value
  admin_sa = {
    api_key    = var.kafka_api_key
    api_secret = var.kafka_api_secret
  }
}

##
## CREATING SCHEMAS
##

module "schema" {
  for_each = { for path in fileset(path.module, "../env/dev/${var.project}/${var.project_env}/schemas/*.avsc") : path => path }
  source   = "./modules/schema"
  path     = each.value
  format   = "AVRO"
  subject  = replace(basename(each.value), ".avsc", "")
  env_id   = data.confluent_environment.env.id
}

##
## CREATING SERVICE ACCOUNT
##

module "service_account" {
  for_each       = { for sa in local.rbacs.serviceaccounts : sa.name => sa }
  source         = "./modules/serviceaccount"
  serviceaccount = each.value
}

##
## CREATING RBAC
##

module "rbac_kafka" {
  for_each             = { for rbac in local.rbacs.rbacs.kafka : format("%s/%s", rbac.resource, rbac.role) => rbac }
  source               = "./modules/rbac"
  env_id               = data.confluent_environment.env.id
  crn                  = "crn://confluent.cloud/organization=${data.confluent_organization.org.id}/environment=${var.env_id}/cloud-cluster=${var.kafka_id}/kafka=${var.kafka_id}/topic=${each.value.resource}"
  identity_pool_name   = var.project
  identity_provider_id = var.identity_provider_id
  role                 = each.value.role
}

module "rbac_schema_registry" {
  for_each             = { for rbac in local.rbacs.rbacs.schema_registry : format("%s/%s", rbac.resource, rbac.role) => rbac }
  source               = "./modules/rbac"
  env_id               = data.confluent_environment.env.id
  crn                  = "crn://confluent.cloud/organization=${data.confluent_organization.org.id}/environment=${var.env_id}/schema-registry=${data.confluent_schema_registry_cluster.cluster.id}/subject=${each.value.resource}"
  identity_pool_name   = var.project
  identity_provider_id = var.identity_provider_id
  role                 = each.value.role
}

