variable "project" {
  description = "Project to deploy resources for"
  type        = string
}

variable "project_env" {
  description = "Project environment to deploy resources for"
  type        = string
}

variable "env_id" {
  description = "ID of the Confluent Cloud environment environment"
  type        = string
}

variable "kafka_id" {
  description = "ID of the Confluent Cloud cluster to leverage (lkc)"
  type        = string
}

variable "cloud_api_key" {
  description = "Cloud API Key with global permission to create the required resources"
  type        = string
}

variable "cloud_api_secret" {
  description = "Cloud API secret with global permission to create the required resources"
  type        = string
}

variable "kafka_api_key" {
  description = "Cloud API Key with global permission to create the required resources"
  type        = string
}

variable "kafka_api_secret" {
  description = "Cloud API secret with global permission to create the required resources"
  type        = string
}

variable "schema_registry_region" {
  description = "Azure Region used for the Schema Registry"
  type        = string
}

variable "schema_registry_cloud" {
  description = "Azure Region used for the Schema Registry and Kafka"
  type        = string
}

variable "identity_provider_id" {
  type = string
}
