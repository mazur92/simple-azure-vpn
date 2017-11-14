output "vpn-machine-ip" {
  value = "${data.azurerm_public_ip.simple-azure-vpn-ip-data.ip_address}"
}
