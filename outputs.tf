output "lb_pip" {
  description = "Load balancer public ip"
  value       = azurerm_public_ip.lbpip.ip_address
}