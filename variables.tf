variable "location" {
  description = "Azure location, defaults to uksouth"
  type        = string
  default     = "uksouth"
  nullable    = false
}

variable "environment_name" {
  description = "Name of the environment e.g. test, staging, production"
  type        = string
  nullable    = false
}

variable "service_bus_namespaces" {
  description = "Azure service bus namespaces"
  type = list(object({
    name         = string
    cost_centre  = string
    product_name = string
    queues       = list(string)
  }))
  nullable = false
}
