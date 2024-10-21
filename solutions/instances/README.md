# Security and Compliance Center instances solution

This solution supports provisioning and configuring the following infrastructure:

- A resource group, if one is not passed in.
- A Security and Compliance Center instance.
- A Security and Compliance Center Workload Protection instance.
- An IBM Cloud Object Storage instance and KMS-encrypted bucket, which is required to store Security and Compliance Center data.
- Security and Compliance Center profile attachments configured for the instance created by this module.

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.70.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.12.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | terraform-ibm-modules/cos/ibm//modules/buckets | 8.11.14 |
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm//modules/fscloud | 8.11.14 |
| <a name="module_create_profile_attachment"></a> [create\_profile\_attachment](#module\_create\_profile\_attachment) | terraform-ibm-modules/scc/ibm//modules/attachment | 1.8.10 |
| <a name="module_existing_cos_crn_parser"></a> [existing\_cos\_crn\_parser](#module\_existing\_cos\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_en_crn_parser"></a> [existing\_en\_crn\_parser](#module\_existing\_en\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.0.0 |
| <a name="module_existing_kms_crn_parser"></a> [existing\_kms\_crn\_parser](#module\_existing\_kms\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_existing_scc_crn_parser"></a> [existing\_scc\_crn\_parser](#module\_existing\_scc\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.0.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/kms-all-inclusive/ibm | 4.15.13 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |
| <a name="module_scc"></a> [scc](#module\_scc) | terraform-ibm-modules/scc/ibm | 1.8.12 |
| <a name="module_scc_wp"></a> [scc\_wp](#module\_scc\_wp) | terraform-ibm-modules/scc-workload-protection/ibm | 1.4.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_en_subscription_email.email_subscription](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/resources/en_subscription_email) | resource |
| [ibm_en_topic.en_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/resources/en_topic) | resource |
| [ibm_iam_authorization_policy.cos_kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/resources/iam_authorization_policy) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) | resource |
| [time_sleep.wait_for_scc](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) | resource |
| [ibm_en_destinations.en_destinations](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/data-sources/en_destinations) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/data-sources/iam_account_settings) | data source |
| [ibm_resource_group.group](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.70.1/docs/data-sources/resource_group) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_bucket_name_suffix"></a> [add\_bucket\_name\_suffix](#input\_add\_bucket\_name\_suffix) | Whether to add a generated 4-character suffix to the created Security and Compliance Center Object Storage bucket name. Applies only if not specifying an existing bucket. Set to `false` not to add the suffix to the bucket name in the `scc_cos_bucket_name` variable. | `bool` | `true` | no |
| <a name="input_attachment_schedule"></a> [attachment\_schedule](#input\_attachment\_schedule) | The scanning schedule. Possible values: `daily`, `every_7_days`, `every_30_days`, `none`. | `string` | `"every_30_days"` | no |
| <a name="input_cos_instance_access_tags"></a> [cos\_instance\_access\_tags](#input\_cos\_instance\_access\_tags) | A list of access tags to apply to the Object Storage instance. Applies only if not specifying an existing instance. | `list(string)` | `[]` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name for the Object Storage instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"base-security-services-cos"` | no |
| <a name="input_cos_instance_tags"></a> [cos\_instance\_tags](#input\_cos\_instance\_tags) | The list of tags to add to the Object Storage instance. Applies only if not specifying an existing instance. | `list(string)` | `[]` | no |
| <a name="input_cos_region"></a> [cos\_region](#input\_cos\_region) | The region for the Object Storage instance. | `string` | `"us-south"` | no |
| <a name="input_existing_activity_tracker_crn"></a> [existing\_activity\_tracker\_crn](#input\_existing\_activity\_tracker\_crn) | The CRN of an Activity Tracker instance to send Security and Compliance Object Storage bucket events to. If no value passed, events are sent to the instance associated to the container's location unless otherwise specified in the Activity Tracker Event Routing service configuration. Ignored if using existing Object Storage bucket. | `string` | `null` | no |
| <a name="input_existing_cos_instance_crn"></a> [existing\_cos\_instance\_crn](#input\_existing\_cos\_instance\_crn) | The CRN of an existing Object Storage instance. If not specified, an instance is created. | `string` | `null` | no |
| <a name="input_existing_en_crn"></a> [existing\_en\_crn](#input\_existing\_en\_crn) | The CRN of an Event Notification instance. Used to integrate with Security and Compliance Center. | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the existing KMS instance (Hyper Protect Crypto Services or Key Protect). If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`. | `string` | `null` | no |
| <a name="input_existing_monitoring_crn"></a> [existing\_monitoring\_crn](#input\_existing\_monitoring\_crn) | The CRN of an IBM Cloud Monitoring instance to to send Security and Compliance Object Storage bucket metrics to, as well as Workload Protection data. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration. Ignored if using existing Object Storage bucket and not provisioning Workload Protection. | `string` | `null` | no |
| <a name="input_existing_scc_cos_bucket_name"></a> [existing\_scc\_cos\_bucket\_name](#input\_existing\_scc\_cos\_bucket\_name) | The name of an existing bucket inside the existing Object Storage instance to use for Security and Compliance Center. If not specified, a bucket is created. | `string` | `null` | no |
| <a name="input_existing_scc_cos_kms_key_crn"></a> [existing\_scc\_cos\_kms\_key\_crn](#input\_existing\_scc\_cos\_kms\_key\_crn) | The CRN of an existing KMS key to use to encrypt the Security and Compliance Center Object Storage bucket. If no value is set for this variable, specify a value for either the `existing_kms_instance_crn` variable to create a key ring and key, or for the `existing_scc_cos_bucket_name` variable to use an existing bucket. | `string` | `null` | no |
| <a name="input_existing_scc_instance_crn"></a> [existing\_scc\_instance\_crn](#input\_existing\_scc\_instance\_crn) | The CRN of an existing Security and Compliance Center instance. If not supplied, a new instance will be created. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to deploy resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_kms_api_key"></a> [ibmcloud\_kms\_api\_key](#input\_ibmcloud\_kms\_api\_key) | The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud\_api\_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Security and Compliance Centre instance. Leave this input empty if the same account owns both instances. | `string` | `null` | no |
| <a name="input_kms_endpoint_type"></a> [kms\_endpoint\_type](#input\_kms\_endpoint\_type) | The endpoint for communicating with the KMS instance. Possible values: `public`, `private.` | `string` | `"private"` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM Terraform provider to use to manage Object Storage buckets. Possible values: `public`, `private`m `direct`. If you specify `private`, enable virtual routing and forwarding in your account, and the Terraform runtime must have access to the the IBM Cloud private network. | `string` | `"private"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to add to all resources created by this solution. | `string` | `null` | no |
| <a name="input_profile_attachments"></a> [profile\_attachments](#input\_profile\_attachments) | The list of Security and Compliance Center profile attachments to create that are scoped to your IBM Cloud account. The attachment schedule runs daily and defaults to the latest version of the specified profile attachments. | `list(string)` | <pre>[<br/>  "IBM Cloud Framework for Financial Services"<br/>]</pre> | no |
| <a name="input_provision_scc_workload_protection"></a> [provision\_scc\_workload\_protection](#input\_provision\_scc\_workload\_protection) | Whether to provision a Workload Protection instance. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | n/a | yes |
| <a name="input_resource_groups_scope"></a> [resource\_groups\_scope](#input\_resource\_groups\_scope) | The resource group to associate with the Security and Compliance Center profile attachments. If not specified, the attachments are scoped to the current account ID. Only one resource group is allowed. | `list(string)` | `[]` | no |
| <a name="input_scc_cos_bucket_access_tags"></a> [scc\_cos\_bucket\_access\_tags](#input\_scc\_cos\_bucket\_access\_tags) | The list of access tags to add to the Security and Compliance Center Object Storage bucket. | `list(string)` | `[]` | no |
| <a name="input_scc_cos_bucket_class"></a> [scc\_cos\_bucket\_class](#input\_scc\_cos\_bucket\_class) | The storage class of the newly provisioned Security and Compliance Center Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes). | `string` | `"smart"` | no |
| <a name="input_scc_cos_bucket_name"></a> [scc\_cos\_bucket\_name](#input\_scc\_cos\_bucket\_name) | The name for the Security and Compliance Center Object Storage bucket. Bucket names must globally unique. If `add_bucket_name_suffix` is true, a 4-character string is added to this name to  ensure it's globally unique. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"base-security-services-bucket"` | no |
| <a name="input_scc_cos_key_name"></a> [scc\_cos\_key\_name](#input\_scc\_cos\_key\_name) | The name for the key created for the Security and Compliance Center Object Storage bucket. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"scc-cos-key"` | no |
| <a name="input_scc_cos_key_ring_name"></a> [scc\_cos\_key\_ring\_name](#input\_scc\_cos\_key\_ring\_name) | The name for the key ring created for the Security and Compliance Center Object Storage bucket key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"scc-cos-key-ring"` | no |
| <a name="input_scc_en_email_list"></a> [scc\_en\_email\_list](#input\_scc\_en\_email\_list) | The list of email addresses to notify when Security and Compliance Center triggers an event. | `list(string)` | `[]` | no |
| <a name="input_scc_en_from_email"></a> [scc\_en\_from\_email](#input\_scc\_en\_from\_email) | The `from` email address used in any Security and Compliance Center events from Event Notifications. | `string` | `"compliancealert@ibm.com"` | no |
| <a name="input_scc_en_reply_to_email"></a> [scc\_en\_reply\_to\_email](#input\_scc\_en\_reply\_to\_email) | The `reply_to` email address used in any Security and Compliance Center events from Event Notifications. | `string` | `"no-reply@ibm.com"` | no |
| <a name="input_scc_instance_name"></a> [scc\_instance\_name](#input\_scc\_instance\_name) | The name for the Security and Compliance Center instance provisioned by this solution. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"base-security-services-scc"` | no |
| <a name="input_scc_instance_tags"></a> [scc\_instance\_tags](#input\_scc\_instance\_tags) | The list of tags to add to the Security and Compliance Center instance. | `list(string)` | `[]` | no |
| <a name="input_scc_region"></a> [scc\_region](#input\_scc\_region) | The region to provision Security and Compliance Center resources in. | `string` | `"us-south"` | no |
| <a name="input_scc_service_plan"></a> [scc\_service\_plan](#input\_scc\_service\_plan) | The pricing plan to use when creating a new Security Compliance Center instance. Possible values: `security-compliance-center-standard-plan`, `security-compliance-center-trial-plan`. Applies only if `existing_scc_instance_crn` is not provided. | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_scc_workload_protection_access_tags"></a> [scc\_workload\_protection\_access\_tags](#input\_scc\_workload\_protection\_access\_tags) | A list of access tags to apply to the Workload Protection instance. Maximum length: 128 characters. Possible characters are A-Z, 0-9, spaces, underscores, hyphens, periods, and colons. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits). | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_instance_name"></a> [scc\_workload\_protection\_instance\_name](#input\_scc\_workload\_protection\_instance\_name) | The name for the Workload Protection instance that is created by this solution. Must begin with a letter. Applies only if `provision_scc_workload_protection` is true. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"base-security-services-scc-wp"` | no |
| <a name="input_scc_workload_protection_instance_tags"></a> [scc\_workload\_protection\_instance\_tags](#input\_scc\_workload\_protection\_instance\_tags) | The list of tags to add to the Workload Protection instance. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_resource_key_tags"></a> [scc\_workload\_protection\_resource\_key\_tags](#input\_scc\_workload\_protection\_resource\_key\_tags) | The tags associated with the Workload Protection resource key. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_service_plan"></a> [scc\_workload\_protection\_service\_plan](#input\_scc\_workload\_protection\_service\_plan) | The pricing plan for the Workload Protection instance service. Possible values: `free-trial`, `graduated-tier`. | `string` | `"graduated-tier"` | no |
| <a name="input_skip_cos_kms_auth_policy"></a> [skip\_cos\_kms\_auth\_policy](#input\_skip\_cos\_kms\_auth\_policy) | Set to `true` to skip the creation of an IAM authorization policy that permits the Object Storage instance created to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account. | `bool` | `false` | no |
| <a name="input_skip_scc_cos_auth_policy"></a> [skip\_scc\_cos\_auth\_policy](#input\_skip\_scc\_cos\_auth\_policy) | Set to `true` to skip creation of an IAM authorization policy that permits the Security and Compliance Center to write to the Object Storage instance created by this solution. Applies only if `existing_scc_instance_crn` is not provided. | `bool` | `false` | no |
| <a name="input_skip_scc_workload_protection_auth_policy"></a> [skip\_scc\_workload\_protection\_auth\_policy](#input\_skip\_scc\_workload\_protection\_auth\_policy) | Set to `true` to skip creating an IAM authorization policy that permits the Security and Compliance Center instance to read from the Workload Protection instance. Applies only if `provision_scc_workload_protection` is true. | `bool` | `false` | no |
| <a name="input_use_existing_resource_group"></a> [use\_existing\_resource\_group](#input\_use\_existing\_resource\_group) | Whether to use an existing resource group. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_scc_attachment_info"></a> [scc\_attachment\_info](#output\_scc\_attachment\_info) | A list of objects containing attachment id, profile name and profile version for every SCC attachment that is created. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/tree/main/solutions/instances/instances.md). |
| <a name="output_scc_cos_bucket_config"></a> [scc\_cos\_bucket\_config](#output\_scc\_cos\_bucket\_config) | List of buckets created |
| <a name="output_scc_cos_bucket_name"></a> [scc\_cos\_bucket\_name](#output\_scc\_cos\_bucket\_name) | SCC COS bucket name |
| <a name="output_scc_cos_instance_crn"></a> [scc\_cos\_instance\_crn](#output\_scc\_cos\_instance\_crn) | SCC COS instance crn |
| <a name="output_scc_cos_instance_guid"></a> [scc\_cos\_instance\_guid](#output\_scc\_cos\_instance\_guid) | SCC COS instance guid |
| <a name="output_scc_cos_instance_id"></a> [scc\_cos\_instance\_id](#output\_scc\_cos\_instance\_id) | SCC COS instance id |
| <a name="output_scc_cos_instance_name"></a> [scc\_cos\_instance\_name](#output\_scc\_cos\_instance\_name) | SCC COS instance name |
| <a name="output_scc_cos_kms_key_crn"></a> [scc\_cos\_kms\_key\_crn](#output\_scc\_cos\_kms\_key\_crn) | SCC COS KMS Key CRN |
| <a name="output_scc_cos_resource_keys"></a> [scc\_cos\_resource\_keys](#output\_scc\_cos\_resource\_keys) | List of resource keys |
| <a name="output_scc_crn"></a> [scc\_crn](#output\_scc\_crn) | SCC instance CRN |
| <a name="output_scc_guid"></a> [scc\_guid](#output\_scc\_guid) | SCC instance guid |
| <a name="output_scc_id"></a> [scc\_id](#output\_scc\_id) | SCC instance ID |
| <a name="output_scc_name"></a> [scc\_name](#output\_scc\_name) | SCC instance name |
| <a name="output_scc_workload_protection_access_key"></a> [scc\_workload\_protection\_access\_key](#output\_scc\_workload\_protection\_access\_key) | SCC Workload Protection access key |
| <a name="output_scc_workload_protection_api_endpoint"></a> [scc\_workload\_protection\_api\_endpoint](#output\_scc\_workload\_protection\_api\_endpoint) | SCC Workload Protection API endpoint |
| <a name="output_scc_workload_protection_crn"></a> [scc\_workload\_protection\_crn](#output\_scc\_workload\_protection\_crn) | SCC Workload Protection instance CRN |
| <a name="output_scc_workload_protection_id"></a> [scc\_workload\_protection\_id](#output\_scc\_workload\_protection\_id) | SCC Workload Protection instance ID |
| <a name="output_scc_workload_protection_ingestion_endpoint"></a> [scc\_workload\_protection\_ingestion\_endpoint](#output\_scc\_workload\_protection\_ingestion\_endpoint) | SCC Workload Protection instance ingestion endpoint |
| <a name="output_scc_workload_protection_name"></a> [scc\_workload\_protection\_name](#output\_scc\_workload\_protection\_name) | SCC Workload Protection instance name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
