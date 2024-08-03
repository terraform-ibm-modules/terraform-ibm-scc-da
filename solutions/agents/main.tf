#######################################################################################################################
# SCC WP Agent
#######################################################################################################################

module "scc_wp_agent" {
  source                 = "terraform-ibm-modules/scc-workload-protection-agent/ibm"
  version                = "1.2.11"
  access_key             = var.access_key
  cluster_name           = var.cluster_name
  region                 = var.region
  endpoint_type          = var.endpoint_type
  name                   = var.name
  namespace              = var.namespace
  deployment_tag         = var.deployment_tag
  kspm_deploy            = var.kspm_deploy
  node_analyzer_deploy   = var.node_analyzer_deploy
  host_scanner_deploy    = var.host_scanner_deploy
  cluster_scanner_deploy = var.cluster_scanner_deploy

}
