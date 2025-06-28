## OVERVIEW:

Module: terraform-aws-ipsecvpn

This module provisions an AWS Site-to-Site VPN connection using AWS VPN Gateway. Resources to be provisioned are the following:

- aws_customer_gateway: Creates a customer gateway representing the on-premises VPN device.
- aws_vpn_gateway: Optionally creates a virtual private gateway (VGW) and attaches it to the specified VPC.
- aws_vpn_gateway_attachment: Attaches the VGW to the VPC if created
- aws_vpn_connection: Establishes the VPN connection between the AWS VGW and the customer gateway, supporting both static and dynamic routing.
    - Supports configuration of both tunnels, including IKE versions, inside CIDRs, preshared keys, DPD settings, and phase 1/2 parameters.
    - Allows for either user-supplied or auto-generated preshared keys.
- random_password: Generates random preshared keys for each tunnel if not provided.
- random_id: Generates a random suffix for the Secrets Manager secret name to ensure uniqueness.
- aws_secretsmanager_secret & aws_secretsmanager_secret_version: Stores generated preshared keys securely in AWS Secrets Manager.
- data.aws_vpc: Optionally retrieves VPC information if a VPC ID is provided.

Variables:
- var.customer_gw: Customer gateway configuration (ASN, IP, type, name).
- var.vpc_details: VPC details (VPC ID).
- var.create_vgw: Boolean to control VGW creation.
- var.vpn_gw_name: Name tag for the VGW.
- var.gen_vpn_settings: General VPN settings (VGW ID, static routes, CIDRs).
- var.tunnel_settings: Tunnel configuration (IKE versions, preshared key, DPD, phase 1/2 settings).



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_customer_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_secretsmanager_secret.vpn_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.vpn_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_vpn_connection.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_vpn_gateway_attachment.vpn_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) | resource |
| [random_id.secret_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.tunnel_keys](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_vpc.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_vgw"></a> [create\_vgw](#input\_create\_vgw) | create vpn gateway | `bool` | `true` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | additional custom tags | `map(string)` | `{}` | no |
| <a name="input_customer_gw"></a> [customer\_gw](#input\_customer\_gw) | custtomer gateway details | <pre>object({<br/>    ip_address = string<br/>    bgp_asn    = optional(number, 65000)<br/>    name       = string<br/>    type       = optional(string, "ipsec.1")<br/><br/>  })</pre> | n/a | yes |
| <a name="input_gen_vpn_settings"></a> [gen\_vpn\_settings](#input\_gen\_vpn\_settings) | General VPN connection arguments | <pre>object({<br/>    customer_gateway_id      = optional(string)<br/>    transit_gateway_id       = optional(string)<br/>    vpn_gateway_id           = optional(string)<br/>    enable_acceleration      = optional(bool, false)<br/>    local_ipv4_network_cidr  = optional(string)<br/>    remote_ipv4_network_cidr = optional(string)<br/>    static_routes_only       = optional(bool, true)<br/>    tags                     = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_tunnel_settings"></a> [tunnel\_settings](#input\_tunnel\_settings) | Tunnel 1 and 2 configuration | <pre>object({<br/>    inside_cidr                  = optional(string)<br/>    preshared_key                = optional(string)<br/>    dpd_timeout_action           = optional(string, "clear")<br/>    dpd_timeout_seconds          = optional(number, 30)<br/>    ike_versions                 = optional(list(string), ["ikev2"])<br/>    phase1_dh_group_numbers      = optional(list(number), [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])<br/>    phase1_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])<br/>    phase1_integrity_algorithms  = optional(list(string), ["SHA2-256", "SHA2-384", "SHA2-512"])<br/>    phase1_lifetime_seconds      = optional(number, 28800)<br/>    phase2_dh_group_numbers      = optional(list(number), [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])<br/>    phase2_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])<br/>    phase2_integrity_algorithms  = optional(list(string), ["SHA2-256", "SHA2-384", "SHA2-512"])<br/>    phase2_lifetime_seconds      = optional(number, 3600)<br/>    rekey_fuzz_percentage        = optional(number, 100)<br/>    rekey_margin_time_seconds    = optional(number, 540)<br/>    replay_window_size           = optional(number, 1024)<br/>    startup_action               = optional(string, "add")<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_details"></a> [vpc\_details](#input\_vpc\_details) | vpc id and region | <pre>object({<br/>    vpc_id = string<br/>    region = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_vpn_gw_name"></a> [vpn\_gw\_name](#input\_vpn\_gw\_name) | vpn gateway name | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipsec_vpn_details"></a> [ipsec\_vpn\_details](#output\_ipsec\_vpn\_details) | n/a |


## SAMPLE CODE

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
}

provider "aws" {
  region = var.xyz_vpn_config.vpc_details["region"]
  default_tags {
    tags = var.xyz_vpn_config.custom_tags
  }
}

// Module call
module "xyz_vpn" {
  source           = "mkomlaetou/ipsecvpn/aws"
  #version          = "1.0.0"

  vpc_details      = var.xyz_vpn_config["vpc_details"]
  vpn_gw_name      = var.xyz_vpn_config["vpn_gw_name"]
  customer_gw      = var.xyz_vpn_config["customer_gw"]
  gen_vpn_settings = var.xyz_vpn_config["gen_vpn_settings"]
}

// Variable declaration
variable "xyz_vpn_config" {
  default = {
    // vpc_details
    vpc_details = {
      vpc_id = "vpc-xxxxxxxxxxxxxxx"
      region = "eu-west-1"
    }
    // vpn_gw_name
    vpn_gw_name = "xyz_vpn"

    // customer_gw
    customer_gw = {
      ip_address = "41.218.223.10"
      name       = "xyz_customer_gw"
      type       = "ipsec.1"
    }

    // gen_vpn_settings
    gen_vpn_settings = {
      local_ipv4_network_cidr = "10.250.250.0/24"
    }

    // tunnel_settings
    custom_tags = {
      Environment = "lab"
      Purpose     = "aws-training"
    }
  }

}

// local variables
locals {
  default_tags = {
    IacTool = "terraform"
  }
  tags = merge(local.default_tags, var.custom_tags)
}


// VPN details output
output "xyz_vpn_details" {
  value = module.xyz_vpn.ipsec_vpn_details
}


```