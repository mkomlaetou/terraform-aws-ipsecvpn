


output "ipsec_vpn_details" {
  value = {
    "vpn_connection_id"   = aws_vpn_connection.main.id
    "vpn_gateway_id"      = var.create_vgw ? aws_vpn_gateway.main[0].id : var.gen_vpn_settings.vpn_gateway_id
    "vgw_tunnel1_address" = var.create_vgw ? aws_vpn_connection.main.tunnel1_address : null
    "vgw_tunnel2_address" = var.create_vgw ? aws_vpn_connection.main.tunnel2_address : null
    "customer_gateway_id" = aws_customer_gateway.main.id
    "customer_gateway_ip" = aws_customer_gateway.main.ip_address
  }
}