##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# SLZ ROKS Pattern
##############################################################################

module "landing_zone" {
  source                 = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone//patterns//roks//module?ref=v5.28.0"
  region                 = var.region
  prefix                 = var.prefix
  tags                   = var.resource_tags
  add_atracker_route     = false
  enable_transit_gateway = false
}

##############################################################################
# Observability Instances
##############################################################################

module "scc_wp_instance" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "1.3.1"
  name              = "${var.prefix}-scc-wp-instance"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_key_name = "${var.prefix}-key"
}
