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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.66.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm//modules/fscloud | 8.5.3 |
| <a name="module_create_profile_attachment"></a> [create\_profile\_attachment](#module\_create\_profile\_attachment) | terraform-ibm-modules/scc/ibm//modules/attachment | 1.6.3 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/kms-all-inclusive/ibm | 4.13.4 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |
| <a name="module_scc"></a> [scc](#module\_scc) | terraform-ibm-modules/scc/ibm | 1.6.3 |
| <a name="module_scc_wp"></a> [scc\_wp](#module\_scc\_wp) | terraform-ibm-modules/scc-workload-protection/ibm | 1.3.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_en_subscription_email.email_subscription](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.66.0/docs/resources/en_subscription_email) | resource |
| [ibm_en_topic.en_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.66.0/docs/resources/en_topic) | resource |
| [ibm_iam_authorization_policy.cos_kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.66.0/docs/resources/iam_authorization_policy) | resource |
| [ibm_en_destinations.en_destinations](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.66.0/docs/data-sources/en_destinations) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.66.0/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_bucket_name_suffix"></a> [add\_bucket\_name\_suffix](#input\_add\_bucket\_name\_suffix) | Add random generated suffix (4 characters long) to the newly provisioned SCC COS bucket name. Only used if not passing existing bucket. set to false if you want full control over bucket naming using the 'scc\_cos\_bucket\_name' variable. | `bool` | `true` | no |
| <a name="input_cos_instance_access_tags"></a> [cos\_instance\_access\_tags](#input\_cos\_instance\_access\_tags) | A list of access tags to apply to the Cloud Object Storage instance. Only used if not supplying an existing instance. | `list(string)` | `[]` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to use when creating the Cloud Object Storage instance. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"base-security-services-cos"` | no |
| <a name="input_cos_instance_tags"></a> [cos\_instance\_tags](#input\_cos\_instance\_tags) | Optional list of tags to be added to Cloud Object Storage instance. Only used if not supplying an existing instance. | `list(string)` | `[]` | no |
| <a name="input_cos_region"></a> [cos\_region](#input\_cos\_region) | The Cloud Object Storage region. | `string` | `"us-south"` | no |
| <a name="input_existing_activity_tracker_crn"></a> [existing\_activity\_tracker\_crn](#input\_existing\_activity\_tracker\_crn) | (Optional) The CRN of an existing Activity Tracker instance. Used to send SCC COS bucket log data and all object write events to Activity Tracker. Only used if not supplying an existing COS bucket. | `string` | `null` | no |
| <a name="input_existing_cos_instance_crn"></a> [existing\_cos\_instance\_crn](#input\_existing\_cos\_instance\_crn) | The CRN of an existing Cloud Object Storage instance. If not supplied, a new instance will be created. | `string` | `null` | no |
| <a name="input_existing_en_crn"></a> [existing\_en\_crn](#input\_existing\_en\_crn) | (Optional) The CRN of an existing Event Notification instance. Used to integrate with SCC. | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the existed Hyper Protect Crypto Services or Key Protect instance. Only required if not supplying an existing KMS root key and if 'skip\_cos\_kms\_auth\_policy' is true. | `string` | `null` | no |
| <a name="input_existing_monitoring_crn"></a> [existing\_monitoring\_crn](#input\_existing\_monitoring\_crn) | (Optional) The CRN of an existing IBM Cloud Monitoring instance. Used to send all COS bucket request and usage metrics to, as well as SCC workload protection data. Ignored if using existing COS bucket and not provisioning SCC workload protection. | `string` | `null` | no |
| <a name="input_existing_scc_cos_bucket_name"></a> [existing\_scc\_cos\_bucket\_name](#input\_existing\_scc\_cos\_bucket\_name) | The name of an existing bucket inside the existing Cloud Object Storage instance to use for SCC. If not supplied, a new bucket will be created. | `string` | `null` | no |
| <a name="input_existing_scc_cos_kms_key_crn"></a> [existing\_scc\_cos\_kms\_key\_crn](#input\_existing\_scc\_cos\_kms\_key\_crn) | (OPTIONAL) The CRN of an existing KMS key to be used to encrypt the SCC COS bucket. If no value is passed, a value must be passed for either the `existing_kms_instance_crn` input variable if you want to create a new key ring and key, or the `existing_scc_cos_bucket_name` input variable if you want to use an existing bucket. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The API Key to use for IBM Cloud. | `string` | n/a | yes |
| <a name="input_ibmcloud_kms_api_key"></a> [ibmcloud\_kms\_api\_key](#input\_ibmcloud\_kms\_api\_key) | The IBM Cloud API key with access to create a root key and key ring in the key management service instance. If the KMS instance is in a different account, specify a key from that account. If not specified, the ibmcloud\_api\_key variable is used. | `string` | `null` | no |
| <a name="input_kms_endpoint_type"></a> [kms\_endpoint\_type](#input\_kms\_endpoint\_type) | The type of endpoint to be used for commincating with the KMS instance. Allowed values are: 'public' or 'private' (default) | `string` | `"private"` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to use to manage COS buckets. (`public`, `private` or `direct`). Ensure to enable virtual routing and forwarding (VRF) in your account if using `private`, and that the terraform runtime has access to the the IBM Cloud private network. | `string` | `"private"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional) Prefix to append to all resources created by this solution. | `string` | `null` | no |
| <a name="input_profile_attachments"></a> [profile\_attachments](#input\_profile\_attachments) | Optional list of SCC profile attachments to create that will be scoped to your specific IBM Cloud account with a `daily` attachment schedule and defaults to the latest version of the specified profile attachments. | `list(string)` | <pre>[<br>  "IBM Cloud Framework for Financial Services"<br>]</pre> | no |
| <a name="input_provision_scc_workload_protection"></a> [provision\_scc\_workload\_protection](#input\_provision\_scc\_workload\_protection) | Whether to provision an SCC Workload Protection instance. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of a new or an existing resource group in which to provision resources to. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | n/a | yes |
| <a name="input_scc_cos_bucket_access_tags"></a> [scc\_cos\_bucket\_access\_tags](#input\_scc\_cos\_bucket\_access\_tags) | Optional list of access tags to be added to the SCC COS bucket. | `list(string)` | `[]` | no |
| <a name="input_scc_cos_bucket_class"></a> [scc\_cos\_bucket\_class](#input\_scc\_cos\_bucket\_class) | The storage class of the newly provisioned SCC COS bucket. Allowed values are: 'standard', 'vault', 'cold', 'smart' (default value), 'onerate\_active' | `string` | `"smart"` | no |
| <a name="input_scc_cos_bucket_name"></a> [scc\_cos\_bucket\_name](#input\_scc\_cos\_bucket\_name) | The name to use when creating the SCC Cloud Object Storage bucket (NOTE: bucket names are globally unique). If 'add\_bucket\_name\_suffix' is set to true, a random 4 characters will be added to this name to help ensure bucket name is globally unique. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"base-security-services-bucket"` | no |
| <a name="input_scc_cos_key_name"></a> [scc\_cos\_key\_name](#input\_scc\_cos\_key\_name) | The name to give the Key which will be created for the SCC COS bucket. Not used if supplying an existing Key. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"scc-cos-key"` | no |
| <a name="input_scc_cos_key_ring_name"></a> [scc\_cos\_key\_ring\_name](#input\_scc\_cos\_key\_ring\_name) | The name to give the Key Ring which will be created for the SCC COS bucket Key. Not used if supplying an existing Key. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"scc-cos-key-ring"` | no |
| <a name="input_scc_en_email_list"></a> [scc\_en\_email\_list](#input\_scc\_en\_email\_list) | The list of email address to target out when Security and Compliance Center triggers an event | `list(string)` | `[]` | no |
| <a name="input_scc_en_from_email"></a> [scc\_en\_from\_email](#input\_scc\_en\_from\_email) | The email address in the used in the 'from' of any Security and Compliance Center event coming from Event Notifications | `string` | `"compliancealert@ibm.com"` | no |
| <a name="input_scc_en_reply_to_email"></a> [scc\_en\_reply\_to\_email](#input\_scc\_en\_reply\_to\_email) | The email address used in the 'reply\_to' of any Security and Compliance Center event coming from Event Notifications | `string` | `"no-reply@ibm.com"` | no |
| <a name="input_scc_instance_name"></a> [scc\_instance\_name](#input\_scc\_instance\_name) | The name to give the SCC instance that will be provisioned by this solution. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"base-security-services-scc"` | no |
| <a name="input_scc_instance_tags"></a> [scc\_instance\_tags](#input\_scc\_instance\_tags) | Optional list of tags to be added to SCC instance. | `list(string)` | `[]` | no |
| <a name="input_scc_region"></a> [scc\_region](#input\_scc\_region) | The region in which to provision SCC resources. | `string` | `"us-south"` | no |
| <a name="input_scc_service_plan"></a> [scc\_service\_plan](#input\_scc\_service\_plan) | The service/pricing plan to use when provisioning a new Security Compliance Center instance. Allowed values are: 'security-compliance-center-standard-plan' (default value) and 'security-compliance-center-trial-plan'. Only used if `provision_scc_instance` is set to true. | `string` | `"security-compliance-center-standard-plan"` | no |
| <a name="input_scc_workload_protection_access_tags"></a> [scc\_workload\_protection\_access\_tags](#input\_scc\_workload\_protection\_access\_tags) | A list of access tags to apply to the SCC WP instance. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_instance_name"></a> [scc\_workload\_protection\_instance\_name](#input\_scc\_workload\_protection\_instance\_name) | The name to give the SCC Workload Protection instance that will be provisioned by this solution. Must begine with a letter. Only used i 'provision\_scc\_workload\_protection' to true. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'. | `string` | `"base-security-services-scc-wp"` | no |
| <a name="input_scc_workload_protection_instance_tags"></a> [scc\_workload\_protection\_instance\_tags](#input\_scc\_workload\_protection\_instance\_tags) | Optional list of tags to be added to SCC Workload Protection instance. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_resource_key_tags"></a> [scc\_workload\_protection\_resource\_key\_tags](#input\_scc\_workload\_protection\_resource\_key\_tags) | Tags associated with the IBM Cloud SCC WP resource key. | `list(string)` | `[]` | no |
| <a name="input_scc_workload_protection_service_plan"></a> [scc\_workload\_protection\_service\_plan](#input\_scc\_workload\_protection\_service\_plan) | SCC Workload Protection instance service pricing plan. Allowed values are: `free-trial` or `graduated-tier`. | `string` | `"graduated-tier"` | no |
| <a name="input_skip_cos_kms_auth_policy"></a> [skip\_cos\_kms\_auth\_policy](#input\_skip\_cos\_kms\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the KMS instance. WARNING: An authorization policy must exist before an encrypted bucket can be created | `bool` | `false` | no |
| <a name="input_skip_scc_cos_auth_policy"></a> [skip\_scc\_cos\_auth\_policy](#input\_skip\_scc\_cos\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this solution write access to the COS instance. Only used if `provision_scc_instance` is set to true. | `bool` | `false` | no |
| <a name="input_skip_scc_workload_protection_auth_policy"></a> [skip\_scc\_workload\_protection\_auth\_policy](#input\_skip\_scc\_workload\_protection\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the SCC instance created by this solution read access to the workload protection instance. Only used if `provision_scc_workload_protection` is set to true. | `bool` | `false` | no |
| <a name="input_use_existing_resource_group"></a> [use\_existing\_resource\_group](#input\_use\_existing\_resource\_group) | Whether to use an existing resource group. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
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
