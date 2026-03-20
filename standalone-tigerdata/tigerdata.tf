# ── TigerData (Timescale Cloud) ──────────────────────────────────────────────

resource "time_sleep" "wait_for_peering" {
  count           = var.ts_vpc_peering ? 1 : 0
  create_duration = "120s"

  depends_on = [aws_vpc_peering_connection_accepter.tigerdata]
}

resource "timescale_service" "tigerdata" {
  name        = coalesce(var.ts_service_name, "${var.name_prefix}-tigerdata")
  milli_cpu   = var.ts_milli_cpu
  memory_gb   = var.ts_memory_gb
  region_code = coalesce(var.ts_region_code, var.aws_region)
  ha_replicas = var.ts_ha_replicas
  vpc_id      = var.ts_vpc_peering ? timescale_vpcs.tigerdata[0].id : null

  depends_on = [time_sleep.wait_for_peering]
}

# ── VPC Peering (Timescale Cloud ↔ AWS) ──────────────────────────────────────

data "aws_caller_identity" "current" {
  count = var.ts_vpc_peering ? 1 : 0
}

resource "timescale_vpcs" "tigerdata" {
  count       = var.ts_vpc_peering ? 1 : 0
  cidr        = var.ts_vpc_cidr
  name        = "${var.name_prefix}-tigerdata-vpc"
  region_code = coalesce(var.ts_region_code, var.aws_region)
}

resource "timescale_peering_connection" "tigerdata" {
  count            = var.ts_vpc_peering ? 1 : 0
  timescale_vpc_id = timescale_vpcs.tigerdata[0].id
  peer_account_id  = data.aws_caller_identity.current[0].account_id
  peer_region_code = var.aws_region
  peer_vpc_id      = local.vpc_id
  peer_cidr_blocks = [var.vpc_cidr]
}

resource "aws_vpc_peering_connection_accepter" "tigerdata" {
  count                     = var.ts_vpc_peering ? 1 : 0
  vpc_peering_connection_id = timescale_peering_connection.tigerdata[0].accepter_provisioned_id
  auto_accept               = true

  tags = { Name = "${var.name_prefix}-tigerdata-peering" }
}
