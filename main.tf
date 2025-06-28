
##########################
# CUSTOMER GATEWAY CREATION
##########################

resource "aws_customer_gateway" "main" {
  bgp_asn    = var.customer_gw.bgp_asn
  ip_address = var.customer_gw.ip_address
  type       = var.customer_gw.type

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.customer_gw.name
  }
}

##########################
# AWS VGW CREATION
##########################

resource "aws_vpn_gateway" "main" {
  count  = var.create_vgw ? 1 : 0
  vpc_id = var.vpc_details.vpc_id

  tags = {
    Name = var.vpn_gw_name
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  count          = var.create_vgw ? 1 : 0
  vpc_id         = var.vpc_details.vpc_id
  vpn_gateway_id = aws_vpn_gateway.main[0].id
}


##########################
# VPN CONNECTION CREATION
##########################

resource "aws_vpn_connection" "main" {
  vpn_gateway_id           = var.create_vgw ? aws_vpn_gateway.main[0].id : var.gen_vpn_settings.vpn_gateway_id
  customer_gateway_id      = aws_customer_gateway.main.id
  type                     = var.customer_gw.type
  static_routes_only       = var.gen_vpn_settings.static_routes_only
  local_ipv4_network_cidr  = var.gen_vpn_settings.local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.gen_vpn_settings.remote_ipv4_network_cidr == null ? data.aws_vpc.vpc_id[0].cidr_block : var.gen_vpn_settings.remote_ipv4_network_cidr

  # Tunnel 1 configuration
  tunnel1_ike_versions                 = var.tunnel_settings.ike_versions
  tunnel1_inside_cidr                  = var.tunnel_settings.inside_cidr
  tunnel1_preshared_key                = var.tunnel_settings.preshared_key == null ? random_password.tunnel_keys["${var.customer_gw.name}-tunnel1"].result : var.tunnel_settings.preshared_key
  tunnel1_dpd_timeout_action           = var.tunnel_settings.dpd_timeout_action
  tunnel1_dpd_timeout_seconds          = var.tunnel_settings.dpd_timeout_seconds
  tunnel1_phase1_dh_group_numbers      = var.tunnel_settings.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = var.tunnel_settings.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.tunnel_settings.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds      = var.tunnel_settings.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers      = var.tunnel_settings.phase2_dh_group_numbers
  tunnel1_phase2_integrity_algorithms  = var.tunnel_settings.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds      = var.tunnel_settings.phase2_lifetime_seconds

  # Tunnel 2 configuration
  tunnel2_ike_versions                 = var.tunnel_settings.ike_versions
  tunnel2_inside_cidr                  = var.tunnel_settings.inside_cidr
  tunnel2_preshared_key                = var.tunnel_settings.preshared_key == null ? random_password.tunnel_keys["${var.customer_gw.name}-tunnel2"].result : var.tunnel_settings.preshared_key
  tunnel2_dpd_timeout_action           = var.tunnel_settings.dpd_timeout_action
  tunnel2_dpd_timeout_seconds          = var.tunnel_settings.dpd_timeout_seconds
  tunnel2_phase1_dh_group_numbers      = var.tunnel_settings.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = var.tunnel_settings.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.tunnel_settings.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds      = var.tunnel_settings.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers      = var.tunnel_settings.phase2_dh_group_numbers
  tunnel2_phase2_integrity_algorithms  = var.tunnel_settings.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds      = var.tunnel_settings.phase2_lifetime_seconds

  tags = {
    Name = var.customer_gw.name
  }

  depends_on = [ aws_customer_gateway.main, aws_vpn_gateway.main ]

}


############################################################
# CREATION RANDOM PRESHARED KEYS AND STORE IN SECRETS MANAGER
############################################################

# Generate random preshared keys if not specified
resource "random_password" "tunnel_keys" {
  for_each = var.tunnel_settings.preshared_key == null ? toset(["${var.customer_gw.name}-tunnel1", "${var.customer_gw.name}-tunnel2"]) : toset([])

  length  = 32
  upper   = true
  lower   = true
  numeric = true
  special = false
  # Ensure first character is a letter
  override_special = "0123456789"
  keepers = {
    # Change this value to force new key generation
    vpn_name = var.customer_gw.name
  }
}

# Generate random suffix for secret name
resource "random_id" "secret_suffix" {
  byte_length = 4
}

# Store generated keys in Secrets Manager
resource "aws_secretsmanager_secret" "vpn_keys" {
  count = var.tunnel_settings.preshared_key == null ? 1 : 0

  name        = "${var.customer_gw.name}-vpn-preshared-keys-${random_id.secret_suffix.hex}"
  description = "Auto-generated preshared keys for VPN ${var.customer_gw.name}"
}

#
resource "aws_secretsmanager_secret_version" "vpn_keys" {
  count = var.tunnel_settings.preshared_key == null ? 1 : 0

  secret_id = aws_secretsmanager_secret.vpn_keys[0].id
  secret_string = jsonencode({
    tunnel1 = random_password.tunnel_keys["${var.customer_gw.name}-tunnel1"].result
    tunnel2 = random_password.tunnel_keys["${var.customer_gw.name}-tunnel2"].result
    # Removed timestamp to prevent replacement
    note = "Keys will rotate only when vpn_name changes"
  })
}


############################################################
# DATA SOURCES FOR VPC
############################################################
data "aws_vpc" "vpc_id" {
  count = var.vpc_details.vpc_id == null ? 0 : 1
  id    = var.vpc_details.vpc_id
}


