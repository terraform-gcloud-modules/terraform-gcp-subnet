## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name. Example: prod, dev, staging. | `string` | `"dev"` | no |
| gcp\_region | Default GCP region used when a subnet or NAT does not specify its own region. | `string` | n/a | yes |
| google\_compute\_subnetwork\_enabled | Set false to skip creating all google\_compute\_subnetwork resources. | `bool` | `true` | no |
| label\_order | Label order for resource naming. Example: ["name", "environment"]. | `list(any)` | `[]` | no |
| module\_enabled | Master switch. Set false to disable ALL resource creation in this module. | `bool` | `true` | no |
| module\_timeouts | Custom timeout overrides. Supports key: google\_compute\_subnetwork with create/update/delete values. | `any` | `{}` | no |
| name | Name prefix applied to all resources created by this module. | `string` | `"vpc-test"` | no |
| network | The self\_link or name of the VPC network all subnets belong to. | `string` | `""` | no |
| project\_id | GCP project ID where all resources will be created. Required — no default. | `string` | `null` | no |
| subnets | List of subnet objects. Each defines its own CIDR, region, purpose, and optional flow logs. | <pre>list(object({<br><br>    name          = string<br>    ip_cidr_range = string<br><br><br>    region                     = optional(string, "")<br>    description                = optional(string, "")<br>    purpose                    = optional(string, "PRIVATE")<br>    role                       = optional(string, null)<br>    private_ip_google_access   = optional(bool, true)<br>    private_ipv6_google_access = optional(string, null)<br>    stack_type                 = optional(string, "IPV4_ONLY")<br>    ipv6_access_type           = optional(string, null)<br><br><br>    secondary_ip_ranges = optional(list(object({<br>      range_name    = string<br>      ip_cidr_range = string<br>    })), [])<br><br><br>    log_config = optional(object({<br>      aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>      flow_sampling        = optional(number, 0.5)<br>      metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>      filter_expr          = optional(string, "true") # FIX 2: default prevents missing-key error<br>    }), null)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet\_gateway\_addresses | Map of subnet name → default gateway IP address. |
| subnet\_ids | Map of subnet name → subnet ID. Usage: module.subnet.subnet\_ids["web"] |
| subnet\_ip\_cidr\_ranges | Map of subnet name → primary CIDR range. |
| subnet\_names | Map of subnet name → full resource name in GCP. |
| subnet\_projects | Map of subnet name → GCP project ID. |
| subnet\_regions | Map of subnet name → GCP region where subnet lives. |
| subnet\_secondary\_ip\_ranges | Map of subnet name → list of secondary IP ranges. Useful when passing GKE ranges to other modules. |
| subnet\_self\_links | Map of subnet name → self\_link URI. Pass to GKE node pools, VM instances, or other modules. |

