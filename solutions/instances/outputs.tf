########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "scc_id" {
  description = "SCC instance ID"
  value       = module.scc.id
}

output "scc_guid" {
  description = "SCC instance guid"
  value       = module.scc.guid
}

output "scc_crn" {
  description = "SCC instance CRN"
  value       = module.scc.crn
}

output "scc_name" {
  description = "SCC instance name"
  value       = module.scc.name
}

output "scc_workload_protection_id" {
  description = "SCC Workload Protection instance ID"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].id : null
}

output "scc_workload_protection_crn" {
  description = "SCC Workload Protection instance CRN"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].crn : null
}

output "scc_workload_protection_name" {
  description = "SCC Workload Protection instance name"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].name : null
}

output "scc_workload_protection_ingestion_endpoint" {
  description = "SCC Workload Protection instance ingestion endpoint"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].name : null
}

output "scc_workload_protection_api_endpoint" {
  description = "SCC Workload Protection API endpoint"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].api_endpoint : null
  sensitive   = true
}

output "scc_workload_protection_access_key" {
  description = "SCC Workload Protection access key"
  value       = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].access_key : null
  sensitive   = true
}

output "scc_attachment_info" {
  description = "A list of objects containing attachment id, profile name and profile version for every SCC attachment that is created. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/instances/instances.md)."
  value = [
    for attachment in module.create_profile_attachment : {
      attachment_id = attachment.id
      name          = attachment.profile.profile_name
      version       = attachment.profile.profile_version
    }
  ]
}

########################################################################################################################
# SCC COS
########################################################################################################################

output "scc_cos_kms_key_crn" {
  description = "SCC COS KMS Key CRN"
  # if passing an existing bucket, then no KMS key is in play here, so output will be null
  value = var.existing_scc_cos_bucket_name != null ? null : local.scc_cos_kms_key_crn
}

output "scc_cos_bucket_name" {
  description = "SCC COS bucket name"
  value       = var.existing_scc_cos_bucket_name != null ? var.existing_scc_cos_bucket_name : module.buckets.buckets[local.scc_cos_bucket_name].bucket_name
}

output "scc_cos_bucket_config" {
  description = "List of buckets created"
  value       = var.existing_scc_cos_bucket_name != null ? null : module.buckets.buckets[local.scc_cos_bucket_name]
}

output "scc_cos_instance_id" {
  description = "SCC COS instance id"
  value       = var.existing_scc_cos_bucket_name != null ? null : module.cos[0].cos_instance_id
}

output "scc_cos_instance_guid" {
  description = "SCC COS instance guid"
  value       = var.existing_scc_cos_bucket_name != null ? null : module.cos[0].cos_instance_guid
}

output "scc_cos_instance_name" {
  description = "SCC COS instance name"
  value       = var.existing_scc_cos_bucket_name != null ? null : local.cos_instance_name
}

output "scc_cos_instance_crn" {
  description = "SCC COS instance crn"
  value       = var.existing_scc_cos_bucket_name != null ? null : module.cos[0].cos_instance_crn
}

output "scc_cos_resource_keys" {
  description = "List of resource keys"
  value       = var.existing_scc_cos_bucket_name != null ? null : module.cos[0].resource_keys
  sensitive   = true
}
