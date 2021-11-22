output "lb_pip" {
  description = "Load balancer public ip"
  value       = module.lb_vmss.lb_pip
}