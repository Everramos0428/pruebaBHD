output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "dns" {
  value = azurerm_dns_zone.dns.name_servers
}

output "dominio" {
  value = azurerm_dns_zone.dns.name
}