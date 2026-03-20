variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS shared config/credentials profile to use (for example dev, sandbox). If null, SDK default resolution is used."
  type        = string
  default     = null
}

variable "aws_access_key" {
  description = "AWS access key ID. If set, takes precedence over aws_profile."
  type        = string
  default     = null
}

variable "aws_secret_key" {
  description = "AWS secret access key. Required when aws_access_key is set."
  type        = string
  default     = null
  sensitive   = true
}

variable "name_prefix" {
  description = "Prefix used for naming created resources."
  type        = string
  default     = "redundant"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.name_prefix)) && length(var.name_prefix) <= 24
    error_message = "name_prefix must contain only lowercase letters, digits, and hyphens, start with a letter or digit, and be at most 24 characters."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_overrides" {
  description = "Optional list of exactly two AZ names to force placement order [primary, backup]. Leave empty for automatic selection."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zone_overrides) == 0 || length(var.availability_zone_overrides) == 2
    error_message = "availability_zone_overrides must be empty or contain exactly two availability zones."
  }

  validation {
    condition     = length(var.availability_zone_overrides) < 2 || var.availability_zone_overrides[0] != var.availability_zone_overrides[1]
    error_message = "availability_zone_overrides must contain two distinct availability zones."
  }
}

variable "existing_vpc_id" {
  description = "ID of an existing VPC to deploy into. When set, no VPC/subnet/IGW/route-table resources are created."
  type        = string
  default     = null

  validation {
    condition     = var.existing_vpc_id == null || can(regex("^vpc-[0-9a-fA-F]{8,17}$", var.existing_vpc_id))
    error_message = "existing_vpc_id must be a valid VPC ID (e.g. vpc-xxxxxxxx)."
  }
}

variable "existing_subnet_id_primary" {
  description = "ID of an existing subnet for the primary instance. Required when existing_vpc_id is set."
  type        = string
  default     = null

  validation {
    condition     = var.existing_subnet_id_primary == null || can(regex("^subnet-[0-9a-fA-F]{8,17}$", var.existing_subnet_id_primary))
    error_message = "existing_subnet_id_primary must be a valid subnet ID (e.g. subnet-xxxxxxxx)."
  }
}

variable "existing_subnet_id_backup" {
  description = "ID of an existing subnet for the backup instance. Required when existing_vpc_id is set. Must be in a different AZ than the primary subnet."
  type        = string
  default     = null

  validation {
    condition     = var.existing_subnet_id_backup == null || can(regex("^subnet-[0-9a-fA-F]{8,17}$", var.existing_subnet_id_backup))
    error_message = "existing_subnet_id_backup must be a valid subnet ID (e.g. subnet-xxxxxxxx)."
  }
}

variable "ami_id" {
  description = "Optional explicit AMI ID override. If null, the latest Marketplace AMI is resolved from the hardcoded product code."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[0-9a-fA-F]{8,17}$", var.ami_id))
    error_message = "ami_id must look like a valid AMI ID (e.g. ami-xxxxxxxx)."
  }
}

variable "instance_type" {
  description = "EC2 instance type compatible with ARM64/Graviton."
  type        = string
  default     = "t4g.medium"

  validation {
    condition     = can(regex("^[a-z0-9]+g\\.", var.instance_type))
    error_message = "instance_type should be a Graviton family (for example t4g.medium, m7g.large, c7g.xlarge)."
  }
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access."
  type        = string
  default     = null
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to reach SSH (22/TCP). Leave empty to rely on EC2 Instance Connect only."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.ssh_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each entry in ssh_cidr_blocks must be a valid IPv4 CIDR block."
  }
}

variable "webui_cidr_blocks" {
  description = "CIDR blocks allowed to reach the N3uron WebUI (8003/TCP). Leave empty to disable."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.webui_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each entry in webui_cidr_blocks must be a valid IPv4 CIDR block."
  }
}

variable "links_cidr_blocks" {
  description = "CIDR blocks allowed to reach API port 3001/TCP. Leave empty to disable."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.links_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each entry in links_cidr_blocks must be a valid IPv4 CIDR block."
  }
}

variable "extra_ingress_rules" {
  description = "Additional TCP ingress rules for the security group."
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.extra_ingress_rules : rule.port >= 1 && rule.port <= 65535])
    error_message = "Each port must be between 1 and 65535."
  }

  validation {
    condition     = alltrue(flatten([for rule in var.extra_ingress_rules : [for cidr in rule.cidr_blocks : can(cidrhost(cidr, 0))]]))
    error_message = "Each cidr_blocks entry in extra_ingress_rules must be a valid IPv4 CIDR block."
  }
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 40

  validation {
    condition     = var.root_volume_size_gb >= 8
    error_message = "root_volume_size_gb must be at least 8 GB."
  }
}

variable "root_volume_encrypted" {
  description = "Whether root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

# ── TigerData (Timescale Cloud) ──────────────────────────────────────────────

variable "ts_project_id" {
  description = "Timescale Cloud project ID (visible in the Timescale console under Project settings)."
  type        = string
}

variable "ts_access_key" {
  description = "Public key of the Timescale client credentials."
  type        = string
}

variable "ts_secret_key" {
  description = "Secret key of the Timescale client credentials."
  type        = string
  sensitive   = true
}

variable "ts_region_code" {
  description = "Timescale Cloud region for the TigerData service. Uses standard AWS region names (e.g. us-east-1). If null, defaults to var.aws_region."
  type        = string
  default     = null
}

variable "ts_milli_cpu" {
  description = "CPU allocation for the TigerData service in milli-CPU units."
  type        = number
  default     = 500

  validation {
    condition     = contains([500, 1000, 2000, 4000, 8000, 16000, 32000], var.ts_milli_cpu)
    error_message = "ts_milli_cpu must be one of: 500, 1000, 2000, 4000, 8000, 16000, 32000."
  }
}

variable "ts_memory_gb" {
  description = "Memory allocation for the TigerData service in GB."
  type        = number
  default     = 2

  validation {
    condition     = contains([2, 4, 8, 16, 32, 64, 128], var.ts_memory_gb)
    error_message = "ts_memory_gb must be one of: 2, 4, 8, 16, 32, 64, 128."
  }
}

variable "ts_service_name" {
  description = "Name of the TigerData service in Timescale Cloud. If null, defaults to '<name_prefix>-tigerdata'."
  type        = string
  default     = null
}

variable "ts_ha_replicas" {
  description = "Number of HA replicas (0, 1, or 2). 1 = High availability, 2 = Highest availability."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 2], var.ts_ha_replicas)
    error_message = "ts_ha_replicas must be 0, 1, or 2."
  }
}

variable "ts_vpc_peering" {
  description = "Enable VPC peering between the AWS VPC and Timescale Cloud for private connectivity."
  type        = bool
  default     = false
}

variable "ts_vpc_cidr" {
  description = "CIDR block for the Timescale Cloud VPC. Must not overlap with var.vpc_cidr."
  type        = string
  default     = "10.1.0.0/21"

  validation {
    condition     = can(cidrhost(var.ts_vpc_cidr, 0))
    error_message = "ts_vpc_cidr must be a valid IPv4 CIDR block."
  }
}
