# ----------------------------------------------------------------------------------
# LABELLING
# ----------------------------------------------------------------------------------

variable "name" {
  type        = string
  default     = "vpc-test"
  description = "Name prefix applied to all resources created by this module."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name. Example: prod, dev, staging."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order for resource naming. Example: [\"name\", \"environment\"]."
}

# ----------------------------------------------------------------------------------
# CORE — PROJECT & NETWORK
# ----------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  default     = null
  description = "GCP project ID where all resources will be created. Required — no default."
}

variable "network" {
  type        = string
  default     = ""
  description = "The self_link or name of the VPC network all subnets belong to."
}

variable "gcp_region" {
  type        = string
  description = "Default GCP region used when a subnet or NAT does not specify its own region."

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.gcp_region))
    error_message = "gcp_region must be a valid GCP region format. Example: us-central1, europe-west3, asia-south1."
  }
}

# ----------------------------------------------------------------------------------
# SUBNETS — dynamic list
# Each subnet is a fully independent object with its own settings
# ----------------------------------------------------------------------------------

variable "subnets" {
  type = list(object({

    name          = string
    ip_cidr_range = string


    region                     = optional(string, "")
    description                = optional(string, "")
    purpose                    = optional(string, "PRIVATE")
    role                       = optional(string, null)
    private_ip_google_access   = optional(bool, true)
    private_ipv6_google_access = optional(string, null)
    stack_type                 = optional(string, "IPV4_ONLY")
    ipv6_access_type           = optional(string, null)


    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])


    log_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      flow_sampling        = optional(number, 0.5)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      filter_expr          = optional(string, "true") # FIX 2: default prevents missing-key error
    }), null)
  }))

  default     = []
  description = "List of subnet objects. Each defines its own CIDR, region, purpose, and optional flow logs."


  validation {
    condition = alltrue([
      for s in var.subnets :
      can(cidrnetmask(s.ip_cidr_range))
    ])
    error_message = "Every subnet ip_cidr_range must be a valid CIDR. Example: 10.10.0.0/24."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      contains([
        "PRIVATE",
        "PRIVATE_RFC_1918",
        "PRIVATE_SERVICE_CONNECT",
        "REGIONAL_MANAGED_PROXY",
        "GLOBAL_MANAGED_PROXY",
        "PRIVATE_NAT"
      ], try(s.purpose, "PRIVATE"))
    ])
    error_message = "Each subnet purpose must be one of: PRIVATE, PRIVATE_RFC_1918, PRIVATE_SERVICE_CONNECT, REGIONAL_MANAGED_PROXY, GLOBAL_MANAGED_PROXY, PRIVATE_NAT."
  }

  validation {
    condition = alltrue([
      for s in var.subnets :
      try(s.role, null) == null || contains(["ACTIVE", "BACKUP"], s.role)
    ])
    error_message = "Each subnet role must be ACTIVE, BACKUP, or null."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      contains(["IPV4_ONLY", "IPV4_IPV6"], try(s.stack_type, "IPV4_ONLY"))
    ])
    error_message = "Each subnet stack_type must be IPV4_ONLY or IPV4_IPV6."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      try(s.ipv6_access_type, null) == null || contains(["EXTERNAL", "INTERNAL"], s.ipv6_access_type)
    ])
    error_message = "Each subnet ipv6_access_type must be EXTERNAL, INTERNAL, or null."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      try(s.log_config, null) == null ||
      (try(s.log_config.flow_sampling, 0.5) >= 0 && try(s.log_config.flow_sampling, 0.5) <= 1)
    ])
    error_message = "log_config.flow_sampling must be between 0.0 and 1.0."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      try(s.log_config, null) == null ||
      contains(
        ["INTERVAL_5_SEC", "INTERVAL_30_SEC", "INTERVAL_1_MIN", "INTERVAL_5_MIN", "INTERVAL_10_MIN", "INTERVAL_15_MIN"],
        try(s.log_config.aggregation_interval, "INTERVAL_5_SEC")
      )
    ])
    error_message = "log_config.aggregation_interval must be one of: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN."
  }


  validation {
    condition = alltrue([
      for s in var.subnets :
      try(s.log_config, null) == null ||
      contains(
        ["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA", "CUSTOM_METADATA"],
        try(s.log_config.metadata, "INCLUDE_ALL_METADATA")
      )
    ])
    error_message = "log_config.metadata must be INCLUDE_ALL_METADATA, EXCLUDE_ALL_METADATA, or CUSTOM_METADATA."
  }


  validation {
    condition = alltrue(flatten([
      for s in var.subnets : [
        for r in(s.secondary_ip_ranges != null ? s.secondary_ip_ranges : []) :
        can(cidrnetmask(r.ip_cidr_range))
      ]
    ]))
    error_message = "Every secondary_ip_range ip_cidr_range must be a valid CIDR. Example: 10.1.0.0/16."
  }
}

# ----------------------------------------------------------------------------------
# MODULE ON/OFF TOGGLES
# ----------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  default     = true
  description = "Master switch. Set false to disable ALL resource creation in this module."
}

variable "google_compute_subnetwork_enabled" {
  type        = bool
  default     = true
  description = "Set false to skip creating all google_compute_subnetwork resources."
}
variable "module_timeouts" {
  type        = any
  default     = {}
  description = "Custom timeout overrides. Supports key: google_compute_subnetwork with create/update/delete values."
}
