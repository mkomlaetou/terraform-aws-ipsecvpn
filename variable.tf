
variable "customer_gw" {
  description = "custtomer gateway details"
  type = object({
    ip_address = string
    bgp_asn    = optional(number, 65000)
    name       = string
    type       = optional(string, "ipsec.1")

  })
}


variable "vpc_details" {
  description = "vpc id and region"
  type = object({
    vpc_id = string
    region = optional(string)
  })
  # default = {}
}

variable "vpn_gw_name" {
  description = "vpn gateway name"
  type        = string
  default     = ""
}

variable "create_vgw" {
  description = "create vpn gateway"
  type        = bool
  default     = true
}



# General VPN connection arguments
variable "gen_vpn_settings" {
  description = "General VPN connection arguments"
  type = object({
    customer_gateway_id      = optional(string)
    transit_gateway_id       = optional(string)
    vpn_gateway_id           = optional(string)
    enable_acceleration      = optional(bool, false)
    local_ipv4_network_cidr  = optional(string)
    remote_ipv4_network_cidr = optional(string)
    static_routes_only       = optional(bool, true)
    tags                     = optional(map(string), {})
  })
  default = {}
}

# Tunnel configuration
variable "tunnel_settings" {
  description = "Tunnel 1 and 2 configuration"
  type = object({
    inside_cidr                  = optional(string)
    preshared_key                = optional(string)
    dpd_timeout_action           = optional(string, "clear")
    dpd_timeout_seconds          = optional(number, 30)
    ike_versions                 = optional(list(string), ["ikev2"])
    phase1_dh_group_numbers      = optional(list(number), [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    phase1_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
    phase1_integrity_algorithms  = optional(list(string), ["SHA2-256", "SHA2-384", "SHA2-512"])
    phase1_lifetime_seconds      = optional(number, 28800)
    phase2_dh_group_numbers      = optional(list(number), [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    phase2_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
    phase2_integrity_algorithms  = optional(list(string), ["SHA2-256", "SHA2-384", "SHA2-512"])
    phase2_lifetime_seconds      = optional(number, 3600)
    rekey_fuzz_percentage        = optional(number, 100)
    rekey_margin_time_seconds    = optional(number, 540)
    replay_window_size           = optional(number, 1024)
    startup_action               = optional(string, "add")
  })
  default = {}
}

// custom tags
variable "custom_tags" {
  description = "additional custom tags"
  type        = map(string)
  default     = {}
}

