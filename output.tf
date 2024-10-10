# Muestra el nombre del grupo de recursos creado.
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# Muestra la dirección IP pública que se ha creado.
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

# Muestra los servidores de nombres de la zona DNS creada.
output "dns" {
  value = azurerm_dns_zone.dns.name_servers
}

# Muestra el nombre del dominio asociado a la zona DNS.
output "dominio" {
  value = azurerm_dns_zone.dns.name
}
