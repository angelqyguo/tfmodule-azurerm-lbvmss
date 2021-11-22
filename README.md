# tfmodule-azurerm-lbvmss
## Terraform module create a test web stack:
- one L3 load balancer with public IP
- backend Ubuntu 20.04 Linux Virtual Machine Scale Set
- install nginx

## Tested provider version
| Provider | Version |
| ----------- | ----------- |
| azurerm | "=2.85.0" |

## Unit test
Using Terratest for terraform module unit testing
