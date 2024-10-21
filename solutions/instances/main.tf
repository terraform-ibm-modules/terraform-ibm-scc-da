#######################################################################################################################
# Validation
#######################################################################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_inputs = var.existing_scc_cos_bucket_name == null && var.existing_scc_cos_kms_key_crn == null && var.existing_kms_instance_crn == null ? tobool("A value must be passed for 'existing_kms_instance_crn' if not supplying any value for 'existing_scc_cos_kms_key_crn' or 'existing_scc_cos_bucket_name'.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_inputs = var.existing_scc_cos_bucket_name != null && var.existing_scc_cos_kms_key_crn != null ? tobool("A value should not be passed for 'existing_scc_cos_kms_key_crn' when passing a value for 'existing_scc_cos_bucket_name'. A key is only needed when creating a new COS bucket.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_auth_inputs = !var.skip_scc_cos_auth_policy && var.existing_cos_instance_crn == null && var.existing_scc_cos_bucket_name != null ? tobool("A value must be passed for 'existing_cos_instance_crn' in order to create auth policy.") : true
}

#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? (var.prefix != null ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

module "existing_kms_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

locals {
  kms_region        = var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].region : null
  existing_kms_guid = var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_instance : null

  scc_cos_key_ring_name                     = var.prefix != null ? "${var.prefix}-${var.scc_cos_key_ring_name}" : var.scc_cos_key_ring_name
  scc_cos_key_name                          = var.prefix != null ? "${var.prefix}-${var.scc_cos_key_name}" : var.scc_cos_key_name
  cos_instance_name                         = var.prefix != null ? "${var.prefix}-${var.cos_instance_name}" : var.cos_instance_name
  scc_instance_name                         = var.prefix != null ? "${var.prefix}-${var.scc_instance_name}" : var.scc_instance_name
  scc_workload_protection_instance_name     = var.prefix != null ? "${var.prefix}-${var.scc_workload_protection_instance_name}" : var.scc_workload_protection_instance_name
  scc_workload_protection_resource_key_name = var.prefix != null ? "${var.prefix}-${var.scc_workload_protection_instance_name}-key" : "${var.scc_workload_protection_instance_name}-key"
  scc_cos_bucket_name                       = var.prefix != null ? "${var.prefix}-${var.scc_cos_bucket_name}" : var.scc_cos_bucket_name
  create_cross_account_auth_policy          = !var.skip_cos_kms_auth_policy && var.ibmcloud_kms_api_key == null ? false : (data.ibm_iam_account_settings.iam_account_settings.account_id != module.existing_kms_crn_parser[0].account_id)

  kms_service_name = var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_name : null
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key, if cross account KMS is passed in
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  count                       = local.create_cross_account_auth_policy ? 1 : 0
  provider                    = ibm.kms
  source_service_account      = data.ibm_iam_account_settings.iam_account_settings.account_id
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  target_service_name         = local.kms_service_name
  target_resource_instance_id = local.existing_kms_guid
  roles                       = ["Reader"]
  description                 = "Allow COS instance in the account ${data.ibm_iam_account_settings.iam_account_settings.account_id} to read from the ${local.kms_service_name} instance GUID ${local.existing_kms_guid}"
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cos_kms_policy]
  count      = local.create_cross_account_auth_policy ? 1 : 0

  create_duration = "30s"
}

# KMS root key for SCC COS bucket
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = (var.existing_scc_cos_kms_key_crn != null || var.existing_scc_cos_bucket_name != null) && var.existing_scc_instance_crn == null ? 0 : 1 # no need to create any KMS resources if passing an existing key or bucket, or SCC instance
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.15.13"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = local.scc_cos_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = local.scc_cos_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

#######################################################################################################################
# COS
#######################################################################################################################

module "existing_cos_crn_parser" {
  count   = var.existing_cos_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_cos_instance_crn
}

locals {
  scc_cos_kms_key_crn = var.existing_scc_cos_bucket_name != null ? null : var.existing_scc_cos_kms_key_crn != null ? var.existing_scc_cos_kms_key_crn : module.kms[0].keys[format("%s.%s", local.scc_cos_key_ring_name, local.scc_cos_key_name)].crn
  cos_instance_crn    = var.existing_cos_instance_crn != null ? var.existing_cos_instance_crn : module.cos[0].cos_instance_crn
  cos_bucket_name     = var.existing_scc_cos_bucket_name != null ? var.existing_scc_cos_bucket_name : local.create_cross_account_auth_policy ? module.buckets[0].buckets[local.scc_cos_bucket_name].bucket_name : module.cos[0].buckets[local.scc_cos_bucket_name].bucket_name
  cos_instance_guid   = var.existing_cos_instance_crn != null ? module.existing_cos_crn_parser[0].service_instance : module.cos[0].cos_instance_guid
  bucket_config = [{
    access_tags                   = var.scc_cos_bucket_access_tags
    add_bucket_name_suffix        = var.add_bucket_name_suffix
    bucket_name                   = local.scc_cos_bucket_name
    kms_encryption_enabled        = true
    kms_guid                      = local.existing_kms_guid
    kms_key_crn                   = local.scc_cos_kms_key_crn
    skip_iam_authorization_policy = local.create_cross_account_auth_policy || var.skip_cos_kms_auth_policy
    management_endpoint_type      = var.management_endpoint_type_for_bucket
    storage_class                 = var.scc_cos_bucket_class
    resource_instance_id          = local.cos_instance_crn
    region_location               = var.cos_region
    force_delete                  = true
    activity_tracking = {
      read_data_events     = true
      write_data_events    = true
      management_events    = true
      activity_tracker_crn = var.existing_activity_tracker_crn
    }
    metrics_monitoring = {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.existing_monitoring_crn
    }
  }]
}

module "cos" {
  providers = {
    ibm = ibm.cos
  }
  count                    = var.existing_scc_cos_bucket_name == null && var.existing_scc_instance_crn == null ? 1 : 0 # no need to call COS module if consumer is passing existing SCC instance or COS bucket
  source                   = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version                  = "8.11.14"
  resource_group_id        = module.resource_group.resource_group_id
  create_cos_instance      = var.existing_cos_instance_crn == null ? true : false # don't create instance if existing one passed in
  cos_instance_name        = local.cos_instance_name
  cos_tags                 = var.cos_instance_tags
  existing_cos_instance_id = var.existing_cos_instance_crn
  access_tags              = var.cos_instance_access_tags
  cos_plan                 = "standard"
  bucket_configs           = local.create_cross_account_auth_policy ? [] : local.bucket_config
}

module "buckets" {
  providers = {
    ibm = ibm.cos
  }
  count          = local.create_cross_account_auth_policy ? 1 : 0
  depends_on     = [time_sleep.wait_for_authorization_policy[0]]
  source         = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version        = "8.11.14"
  bucket_configs = local.bucket_config
}

#######################################################################################################################
# SCC Instance
#######################################################################################################################

module "existing_scc_crn_parser" {
  count   = var.existing_scc_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.0.0"
  crn     = var.existing_scc_instance_crn
}

locals {
  existing_scc_instance_region = var.existing_scc_instance_crn != null ? module.existing_scc_crn_parser[0].region : null
  scc_instance_region          = var.existing_scc_instance_crn == null ? var.scc_region : local.existing_scc_instance_region
}

moved {
  from = module.scc[0]
  to   = module.scc
}

module "scc" {
  source                            = "terraform-ibm-modules/scc/ibm"
  existing_scc_instance_crn         = var.existing_scc_instance_crn
  version                           = "1.8.12"
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = local.scc_instance_region
  instance_name                     = local.scc_instance_name
  plan                              = var.scc_service_plan
  cos_bucket                        = local.cos_bucket_name
  cos_instance_crn                  = local.cos_instance_crn
  en_instance_crn                   = var.existing_en_crn
  skip_cos_iam_authorization_policy = var.skip_scc_cos_auth_policy
  resource_tags                     = var.scc_instance_tags
  attach_wp_to_scc_instance         = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null
  wp_instance_crn                   = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? module.scc_wp[0].crn : null
  skip_scc_wp_auth_policy           = var.skip_scc_workload_protection_auth_policy
}

#######################################################################################################################
# SCC Attachment
#######################################################################################################################

locals {
  resource_group_supplied = length(var.resource_groups_scope) == 1
}

data "ibm_resource_group" "group" {
  count = local.resource_group_supplied ? 1 : 0
  name  = var.resource_groups_scope[0]
}

locals {
  account_scope = {
    environment = "ibm-cloud"
    properties = [
      {
        name  = "scope_type"
        value = "account"
      },
      {
        name  = "scope_id"
        value = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
    ]
  }

  resource_group_scope = {
    environment = "ibm-cloud"
    properties = [
      {
        name  = "scope_type"
        value = "account.resource_group"
      },
      {
        name  = "scope_id"
        value = local.resource_group_supplied ? data.ibm_resource_group.group[0].id : null
      },
    ]
  }

  scope = local.resource_group_supplied ? [local.account_scope, local.resource_group_scope] : [local.account_scope]
}

# Data source to account settings
data "ibm_iam_account_settings" "iam_account_settings" {}

module "create_profile_attachment" {
  source  = "terraform-ibm-modules/scc/ibm//modules/attachment"
  version = "1.8.10"
  for_each = {
    for idx, profile_attachment in var.profile_attachments :
    profile_attachment => idx
  }
  profile_name           = each.key
  profile_version        = "latest"
  scc_instance_id        = module.scc.guid
  attachment_name        = "${each.value + 1} daily full account attachment"
  attachment_description = "SCC profile attachment scoped to your specific IBM Cloud account id ${data.ibm_iam_account_settings.iam_account_settings.account_id} with a daily attachment schedule."
  attachment_schedule    = var.attachment_schedule
  scope                  = local.scope
}

#######################################################################################################################
# SCC Workload Protection
#######################################################################################################################

module "scc_wp" {
  count                         = var.provision_scc_workload_protection && var.existing_scc_instance_crn == null ? 1 : 0
  source                        = "terraform-ibm-modules/scc-workload-protection/ibm"
  version                       = "1.4.0"
  name                          = local.scc_workload_protection_instance_name
  region                        = var.scc_region
  resource_group_id             = module.resource_group.resource_group_id
  resource_tags                 = var.scc_workload_protection_instance_tags
  resource_key_name             = local.scc_workload_protection_resource_key_name
  resource_key_tags             = var.scc_workload_protection_resource_key_tags
  cloud_monitoring_instance_crn = var.existing_monitoring_crn
  access_tags                   = var.scc_workload_protection_access_tags
  scc_wp_service_plan           = var.scc_workload_protection_service_plan
}

#######################################################################################################################
# SCC Event Notifications Configuration
#######################################################################################################################

module "existing_en_crn_parser" {
  count   = var.existing_en_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.0.0"
  crn     = var.existing_en_crn
}

locals {
  existing_en_guid      = var.existing_en_crn != null ? module.existing_en_crn_parser[0].service_instance : null
  en_topic              = var.prefix != null ? "${var.prefix} - SCC Topic" : "SCC Topic"
  en_subscription_email = var.prefix != null ? "${var.prefix} - Email for Security and Compliance Center Subscription" : "Email for Security and Compliance Center Subscription"
}

data "ibm_en_destinations" "en_destinations" {
  count         = var.existing_en_crn != null ? 1 : 0
  instance_guid = local.existing_en_guid
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5533.
resource "time_sleep" "wait_for_scc" {
  depends_on = [module.scc]

  create_duration = "60s"
}

resource "ibm_en_topic" "en_topic" {
  count         = var.existing_en_crn != null && var.existing_scc_instance_crn == null ? 1 : 0
  depends_on    = [time_sleep.wait_for_scc]
  instance_guid = local.existing_en_guid
  name          = local.en_topic
  description   = "Topic for SCC events routing"
  sources {
    id = module.scc.crn
    rules {
      enabled           = true
      event_type_filter = "$.*"
    }
  }
}

resource "ibm_en_subscription_email" "email_subscription" {
  count          = var.existing_en_crn != null && var.existing_scc_instance_crn == null && length(var.scc_en_email_list) > 0 ? 1 : 0
  instance_guid  = local.existing_en_guid
  name           = local.en_subscription_email
  description    = "Subscription for Security and Compliance Center Events"
  destination_id = [for s in toset(data.ibm_en_destinations.en_destinations[count.index].destinations) : s.id if s.type == "smtp_ibm"][0]
  topic_id       = ibm_en_topic.en_topic[count.index].topic_id
  attributes {
    add_notification_payload = true
    reply_to_mail            = var.scc_en_reply_to_email
    reply_to_name            = "SCC Event Notifications Bot"
    from_name                = var.scc_en_from_email
    invited                  = var.scc_en_email_list
  }
}
