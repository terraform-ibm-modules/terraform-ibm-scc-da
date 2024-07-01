########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "existing_monitoring_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an existing IBM Cloud Monitoring instance. Used to send all Object Storage bucket request and usage metrics to, as well as Workload Protection data. Ignored if using existing Object Storage bucket and not provisioning Workload Protection."
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources created by this solution."
  default     = null
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existing Hyper Protect Crypto Services or Key Protect instance. Applies only if not supplying an existing KMS root key and if `skip_cos_kms_auth_policy` is true."
}

variable "existing_scc_cos_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS key to use to encrypt the Security and Compliance Center Object Storage bucket. If no value is set for this variable, specify a value for either the `existing_kms_instance_crn` variable to create a key ring and key, or for the `existing_scc_cos_bucket_name` variable to use an existing bucket."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The endpoint for communicating with the KMS instance. Possible values: `public`, `private.`"
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "scc_cos_key_ring_name" {
  type        = string
  default     = "scc-cos-key-ring"
  description = "The name for the key ring created for the Security and Compliance Center Object Storage bucket key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "scc_cos_key_name" {
  type        = string
  default     = "scc-cos-key"
  description = "The name for the key created for the Security and Compliance Center Object Storage bucket. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key with access to create a root key and key ring in the key management service instance. If the KMS instance is in a different account, specify a key from that account. If not specified, the ibmcloud_api_key variable is used."
  sensitive   = true
  default     = null
}

########################################################################################################################
# COS variables
########################################################################################################################

variable "cos_region" {
  type        = string
  default     = "us-south"
  description = "The region for the Object Storage instance."
}

variable "cos_instance_name" {
  type        = string
  default     = "base-security-services-cos"
  description = "The name for the Object Storage instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "cos_instance_tags" {
  type        = list(string)
  description = "The list of tags to add to the Object Storage instance. Applies only if not specifying an existing instance."
  default     = []
}

variable "cos_instance_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Object Storage instance. Applies only if not specifying an existing instance."
  default     = []
}

variable "scc_cos_bucket_name" {
  type        = string
  default     = "base-security-services-bucket"
  description = "The name for the Security and Compliance Center Object Storage bucket. Bucket names must globally unique. If `add_bucket_name_suffix` is true, a 4-character string is added to this name to  ensure it's globally unique. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Whether to add a generated 4-character suffix to the created Security and Compliance Center Object Storage bucket name. Applies only if not specifying an existing bucket. Set to `false` not to add the suffix to the bucket name in the `scc_cos_bucket_name` variable."
  default     = true
}

variable "scc_cos_bucket_access_tags" {
  type        = list(string)
  default     = []
  description = "The list of access tags to add to the Security and Compliance Center Object Storage bucket."
}

variable "scc_cos_bucket_class" {
  type        = string
  default     = "smart"
  description = "The storage class of the newly provisioned Security and Compliance Center Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes)."
  validation {
    condition     = contains(["standard", "vault", "cold", "smart", "onerate_active"], var.scc_cos_bucket_class)
    error_message = "Allowed values for cos_bucket_class are \"standard\", \"vault\",\"cold\", \"smart\", or \"onerate_active\"."
  }
}

variable "existing_cos_instance_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an existing Object Storage instance. If not specified, an instance is created."
}

variable "existing_scc_cos_bucket_name" {
  type        = string
  nullable    = true
  default     = null
  description = "The name of an existing bucket inside the existing Object Storage instance to use for Security and Compliance Center. If not specified, a bucket is created."
}

variable "skip_cos_kms_auth_policy" {
  type        = bool
  description = "Set to `true` to skip the creation of an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created."
  default     = false
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM Terraform provider to use to manage Object Storage buckets. Possible values: `public`, `private`m `direct`. If you specify `private`, enable virtual routing and forwarding in your account, and the Terraform runtime must have access to the the IBM Cloud private network."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}

variable "existing_activity_tracker_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an existing Activity Tracker instance. Used to send Security and Compliance Center Object Storage bucket log data and all object write events to Activity Tracker. Only used if not supplying an existing Object Storage bucket."
}

########################################################################################################################
# SCC variables
########################################################################################################################

variable "scc_instance_name" {
  type        = string
  default     = "base-security-services-scc"
  description = "The name for the Security and Compliance Center instance provisioned by this solution. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "scc_region" {
  type        = string
  default     = "us-south"
  description = "The region to provision Security and Compliance Center resources in."
}

variable "skip_scc_cos_auth_policy" {
  type        = bool
  default     = false
  description = "Set to `true` to skip creation of an IAM authorization policy that permits the Security and Compliance Center to write to the Object Storage instance created by this solution. Applies only if `provision_scc_instance` is true."
}

variable "scc_service_plan" {
  type        = string
  description = "The pricing plan to use when creating a new Security Compliance Center instance. Possible values: `security-compliance-center-standard-plan`, `security-compliance-center-trial-plan`. Applies only if `provision_scc_instance` is true."
  default     = "security-compliance-center-standard-plan"
  validation {
    condition     = contains(["security-compliance-center-standard-plan", "security-compliance-center-trial-plan"], var.scc_service_plan)
    error_message = "Allowed values for scc_service_plan are \"security-compliance-center-standard-plan\" and \"security-compliance-center-trial-plan\"."
  }
}

variable "existing_en_crn" {
  type        = string
  nullable    = true
  default     = null
  description = "The CRN of an Event Notification instance. Used to integrate with Security and Compliance Center."
}

variable "scc_instance_tags" {
  type        = list(string)
  description = "The list of tags to add to the Security and Compliance Center instance."
  default     = []
}

variable "skip_scc_workload_protection_auth_policy" {
  type        = bool
  default     = false
  description = "Set to `true` to skip creating an IAM authorization policy that permits the Security and Compliance Center instance to read from the Workload Protection instance. Applies only if `provision_scc_workload_protection` is true."
}

variable "profile_attachments" {
  type        = list(string)
  description = "The list of Security and Compliance Center profile attachments to create that are scoped to your IBM Cloud account. The attachment schedule runs daily and defaults to the latest version of the specified profile attachments."
  default     = ["IBM Cloud Framework for Financial Services"]
}

########################################################################################################################
# SCC Workload Protection variables
########################################################################################################################

variable "provision_scc_workload_protection" {
  description = "Whether to provision a Workload Protection instance."
  type        = bool
  default     = true
}

variable "scc_workload_protection_instance_name" {
  description = "The name for the Workload Protection instance that is created by this solution. Must begin with a letter. Applies only if `provision_scc_workload_protection` is true. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  type        = string
  default     = "base-security-services-scc-wp"
}

variable "scc_workload_protection_service_plan" {
  description = "The pricing plan for the Workload Protection instance service. Possible values: `free-trial`, `graduated-tier`."
  type        = string
  default     = "graduated-tier"
  validation {
    error_message = "Plan for Workload Protection instances can only be `free-trial` or `graduated-tier`."
    condition = contains(
      ["free-trial", "graduated-tier"],
      var.scc_workload_protection_service_plan
    )
  }
}

variable "scc_workload_protection_instance_tags" {
  type        = list(string)
  description = "The list of tags to add to the Workload Protection instance."
  default     = []
}

variable "scc_workload_protection_resource_key_tags" {
  type        = list(string)
  description = "The tags associated with the Workload Protection resource key."
  default     = []
}

variable "scc_workload_protection_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Workload Protection instance. Maximum length: 128 characters. Possible characters are A-Z, 0-9, spaces, underscores, hyphens, periods, and colons. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.scc_workload_protection_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

########################################################################################################################
# EN Configuration variables
########################################################################################################################

variable "scc_en_from_email" {
  type        = string
  description = "The `from` email address used in any Security and Compliance Center events from Event Notifications."
  default     = "compliancealert@ibm.com"
}

variable "scc_en_reply_to_email" {
  type        = string
  description = "The `reply_to` email address used in any Security and Compliance Center events from Event Notifications."
  default     = "no-reply@ibm.com"
}

variable "scc_en_email_list" {
  type        = list(string)
  description = "The list of email addresses to notify when Security and Compliance Center triggers an event."
  default     = []
}
