########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

########################################################################################################################
# SCC Workload Protection Agent variables
########################################################################################################################

variable "scc_wp_agent_agent_name" {
  type        = string
  description = "Helm release name."
}

variable "scc_wp_agent_agent_namespace" {
  type        = string
  description = "Namespace of the Security and Compliance Workload Protection agent."
  default     = "ibm-scc-wp"
}

variable "scc_wp_agent_cluster_name" {
  type        = string
  description = "Cluster name to add Security and Compliance Workload Protection agent to."
}

variable "scc_wp_agent_access_key" {
  type        = string
  description = "Security and Compliance Workload Protection instance access key."
  sensitive   = true
}

variable "scc_wp_instance_region" {
  type        = string
  description = "Region where Security and Compliance Workload Protection instance is created."
}

variable "scc_wp_agent_endpoint_type" {
  type        = string
  description = "Specify the endpoint (public or private) for the IBM Cloud Security and Compliance Center Workload Protection service."
  default     = "private"
  validation {
    error_message = "The specified endpoint_type can be private or public only."
    condition     = contains(["private", "public"], var.endpoint_type)
  }
}