# ── MongoDB Atlas ─────────────────────────────────────────────────────────────

data "aws_caller_identity" "current" {
  count = var.atlas_vpc_peering ? 1 : 0
}

resource "mongodbatlas_network_container" "this" {
  count            = var.atlas_vpc_peering ? 1 : 0
  project_id       = var.atlas_project_id
  provider_name    = "AWS"
  region_name      = local.atlas_region_name
  atlas_cidr_block = var.atlas_vpc_cidr
}

resource "mongodbatlas_network_peering" "this" {
  count                  = var.atlas_vpc_peering ? 1 : 0
  project_id             = var.atlas_project_id
  container_id           = mongodbatlas_network_container.this[0].container_id
  provider_name          = "AWS"
  accepter_region_name   = var.aws_region
  aws_account_id         = data.aws_caller_identity.current[0].account_id
  route_table_cidr_block = var.vpc_cidr
  vpc_id                 = local.vpc_id
}

resource "aws_vpc_peering_connection_accepter" "atlas" {
  count                     = var.atlas_vpc_peering ? 1 : 0
  vpc_peering_connection_id = mongodbatlas_network_peering.this[0].connection_id
  auto_accept               = true

  tags = { Name = "${var.name_prefix}-atlas-peering" }
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = var.atlas_project_id
  name         = coalesce(var.atlas_cluster_name, "${var.name_prefix}-cluster")
  cluster_type = "REPLICASET"

  depends_on = [aws_vpc_peering_connection_accepter.atlas]

  replication_specs = [
    {
      region_configs = [
        {
          electable_specs = local.is_tenant_tier ? {
            instance_size = var.atlas_instance_size
            } : {
            instance_size = var.atlas_instance_size
            node_count    = 3
          }
          provider_name         = local.is_tenant_tier ? "TENANT" : "AWS"
          backing_provider_name = local.is_tenant_tier ? "AWS" : null
          priority              = 7
          region_name           = local.atlas_region_name
        }
      ]
    }
  ]
}

resource "mongodbatlas_database_user" "this" {
  project_id         = var.atlas_project_id
  username           = var.atlas_db_username
  password           = var.atlas_db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  scopes {
    name = mongodbatlas_advanced_cluster.this.name
    type = "CLUSTER"
  }
}

resource "mongodbatlas_project_ip_access_list" "ec2_primary" {
  count      = var.atlas_vpc_peering ? 0 : 1
  project_id = var.atlas_project_id
  ip_address = aws_eip.primary.public_ip
  comment    = "${var.name_prefix} primary EC2 instance"
}

resource "mongodbatlas_project_ip_access_list" "ec2_backup" {
  count      = var.atlas_vpc_peering ? 0 : 1
  project_id = var.atlas_project_id
  ip_address = aws_eip.backup.public_ip
  comment    = "${var.name_prefix} backup EC2 instance"
}

resource "mongodbatlas_project_ip_access_list" "vpc" {
  count      = var.atlas_vpc_peering ? 1 : 0
  project_id = var.atlas_project_id
  cidr_block = var.vpc_cidr
  comment    = "${var.name_prefix} VPC CIDR"
}
