environment_name = "test"

service_bus_namespaces = [
  {
    name         = "payg"
    cost_centre  = "finance"
    product_name = "payments gateway"
    queues       = ["one", "two"]
  },
  {
    name         = "crm"
    cost_centre  = "sales"
    product_name = "crm"
    queues       = ["alpha", "beta"]
  }
]
