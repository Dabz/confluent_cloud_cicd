variable "env_id" {
  type = string
}

variable "crn" {
  type = string
}

variable "role" {
  type = string
}

variable "admin_sa" {
  type = object({
    api_key    = string
    api_secret = string
  })
}

variable "identity_pool_name" {
  type = string
}

variable "identity_provider_id" {
  type = string
}

