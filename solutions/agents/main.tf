#######################################################################################################################
# SCC WP Agent
#######################################################################################################################

module "scc_wp_agent" {
  source                 = "terraform-ibm-modules/scc-workload-protection-agent/ibm"
  version                = "1.3.20"
  access_key             = var.access_key
  cluster_name           = var.is_vpc_cluster ? data.ibm_container_vpc_cluster.cluster[0].name : data.ibm_container_cluster.cluster[0].name
  region                 = var.region
  endpoint_type          = var.endpoint_type
  name                   = var.name
  namespace              = var.namespace
  deployment_tag         = var.deployment_tag
  kspm_deploy            = var.kspm_deploy
  node_analyzer_deploy   = var.node_analyzer_deploy
  host_scanner_deploy    = var.host_scanner_deploy
  cluster_scanner_deploy = var.cluster_scanner_deploy

  agent_requests_cpu                                      = var.agent_requests_cpu
  agent_requests_memory                                   = var.agent_requests_memory
  agent_limits_cpu                                        = var.agent_limits_cpu
  agent_limits_memory                                     = var.agent_limits_memory
  kspm_collector_requests_cpu                             = var.kspm_collector_requests_cpu
  kspm_collector_requests_memory                          = var.kspm_collector_requests_memory
  kspm_collector_limits_cpu                               = var.kspm_collector_limits_cpu
  kspm_collector_limits_memory                            = var.kspm_collector_limits_memory
  kspm_analyzer_requests_cpu                              = var.kspm_analyzer_requests_cpu
  kspm_analyzer_requests_memory                           = var.kspm_analyzer_requests_memory
  kspm_analyzer_limits_cpu                                = var.kspm_analyzer_limits_cpu
  kspm_analyzer_limits_memory                             = var.kspm_analyzer_limits_memory
  host_scanner_requests_cpu                               = var.host_scanner_requests_cpu
  host_scanner_requests_memory                            = var.host_scanner_requests_memory
  host_scanner_limits_cpu                                 = var.host_scanner_limits_cpu
  host_scanner_limits_memory                              = var.host_scanner_limits_memory
  cluster_scanner_runtimestatusintegrator_requests_cpu    = var.cluster_scanner_runtimestatusintegrator_requests_cpu
  cluster_scanner_runtimestatusintegrator_requests_memory = var.cluster_scanner_runtimestatusintegrator_requests_memory
  cluster_scanner_runtimestatusintegrator_limits_cpu      = var.cluster_scanner_runtimestatusintegrator_limits_cpu
  cluster_scanner_runtimestatusintegrator_limits_memory   = var.cluster_scanner_runtimestatusintegrator_limits_memory
  cluster_scanner_imagesbomextractor_requests_cpu         = var.cluster_scanner_imagesbomextractor_requests_cpu
  cluster_scanner_imagesbomextractor_requests_memory      = var.cluster_scanner_imagesbomextractor_requests_memory
  cluster_scanner_imagesbomextractor_limits_cpu           = var.cluster_scanner_imagesbomextractor_limits_cpu
  cluster_scanner_imagesbomextractor_limits_memory        = var.cluster_scanner_imagesbomextractor_limits_memory
}
