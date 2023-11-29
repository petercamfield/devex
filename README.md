# Clear.Bank Practical Task
Here is my submission for the Clear.Bank practical task, developed on a Mac using Terraform v1.6.4 

See [here](TheoreticalTask.md) for my take on the theoretical task.

## Naming Convention
All of the Azure resources are named using the following convention:

```
cb-{environment}-{namespace}-{optional queue name}-{azure resource abbreviation}
```

Where
* `environment` is the environment name e.g. test, staging, production
* `azure resource abbreviation` is taken from [this list](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)


## variables.tf
I've created a variable to hold a list of Azure Service Bus Namespaces for a particular environment. Each namespace in the list has:
* a name
* the associated cost centre and product name 
* a list of queue names

Here's an example of a `.tfvars` file for the `test` environment:
```yaml
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
```


## main.tf
The [main.tf](main.tf) sets up the Azure provider. It also iterates over the `service_bus_namespaces` variable creating a resource group for each namespace. 

## service_bus.tf
Inside [service_bus.tf](service_bus.tf) the `service_bus_namespaces` variable is iterated to create service bus namespaces inside the associated resource groups with tags added for cost centre, product name and additionally the environment. 

The `queues_by_namespace` local is a projection of the above `service_bus_namespaces` structure to easier iterate and create queues per namespace. Depending on your convention this local variable may move to a `locals.tf` file, but I've kept it here for the purpose of this exercise. 
The resulting structure looks like so (given the above input):
```yaml
[
  { namespace: "payg", name: "one" },
  { namespace: "payg", name: "two" },
  { namespace: "crm",  name: "alpha" },
  { namespace: "crm",  name: "beta" }
]
```

Finally the `queues_by_namespace` projection is iterated to create the queues for each namespace.

## A note about projections
As the key is used to identify Terraform resources it's important to choose a stable value. If the key changes Terraform will destroy and create resources. The projections used for the resource group and namespace use the name of the service bus namespace as the key:
```
for_each = { for namespace in var.service_bus_namespaces : namespace.name => namespace }
``` 
Likewise the key used for the queues consists of `{namespace}_{queue name}`, again changing the namespace or the queue name will destroy and create resources.

## Setup
Run `terraform init` to initialise the working directory. 
Follow the [instructions here](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash) to authenticate Terraform to Azure.

## Testing
Run `terraform test` to run the tests (requires terraform v1.6.0 or later). 
The tests are declared in [service_bus.tftest.hcl](service_bus.tftest.hcl) and check that the resource group, service bus namespace and queues are correctly named. More tests can be added to test various scenarios such as multiple namespaces / queues etc.

Example test run
```bash
❯ terraform test
service_bus.tftest.hcl... in progress
  run "Ensure resource groups are created with correct name"... pass
  run "Ensure service bus namespaces are created with correct name"... pass
  run "Ensure queues are created with correct name"... pass
service_bus.tftest.hcl... tearing down
service_bus.tftest.hcl... pass
```

## Plan / Apply / Destroy
I've added three example `.tfvars` files to the repository to make running straightforward. 

To run
```zsh
terraform plan -var-file={env}.tfvars -out={env}.out 
terraform apply "{env}.out"
terraform destroy -var-file={env}.tfvars
```

where `{env}` is one of `test`, `staging` or `production`.
 
I've included my copy of `test.out` - to view the plan run `terraform show "test.out"`

## Where next
What I haven't done
* Added Azure delete locks - whilst I have prevented accidental deletion by terraform via `prevent_destroy` in the `lifecycle` block, the resources can still be deleted via the Azure portal. 
* Used remote state
* Configured the namespace and queues in any meaningful way.
* Used premium features such as high throughput, scaling, network security, geo-disaster and recovery etc 
* Incorporated a CI / CD pipeline to automate linting, static analysis (tfsec, checkov, etc.), tests, deployment (automatic / gated), etc. 
* Created a module - If the structure were to be repeated anywhere
* Added input variable validation, e.g. ensure at least one service bus namespace is declared and that each namespace has at least one queue. 
* Security hardening / least privilege - Ensure resources are only as visible as they need be depending on resource type and requirements, e.g. no internet ingress, vnet / subnet restrictions, private endpoints etc. Ideally specify particular access rights to resources for each environment - e.g. engineers may have full access to test, and limited access to production. 
* Implemented any Azure policies e.g. ensure zone redundancy for service bus