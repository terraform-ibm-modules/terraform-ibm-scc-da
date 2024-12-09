// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const resourceGroup = "geretain-test-resources"
const instanceFlavorDir = "solutions/instances"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Current supported SCC region
var validRegions = []string{
	"us-south",
	"eu-de",
	"ca-tor",
	"eu-es",
}

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func TestAgentsInSchematics(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------------------------
	// Deploy SLZ ROKS Cluster and SCC Workload Protection instance since it is needed to deploy SCC Workload Protection Agents
	// ------------------------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("slz-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources/agents"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp resources (SLZ-ROKS and Workload SCC Protection Instances) failed")
	} else {

		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  "scc-wp-agt",
			TarIncludePatterns: []string{
				agentFlavorDir + "/*.*",
				agentsKubeconfigDir + "/*.*",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         agentFlavorDir,
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			Region:                 region,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "access_key", Value: terraform.Output(t, existingTerraformOptions, "access_key"), DataType: "string"},
			{Name: "cluster_name", Value: terraform.Output(t, existingTerraformOptions, "workload_cluster_name"), DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "endpoint_type", Value: "private", DataType: "string"},
			{Name: "name", Value: options.Prefix, DataType: "string"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}


func TestInstancesInSchematics(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "scc-da",
		TarIncludePatterns: []string{
			"*.tf",
			instanceFlavorDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         instanceFlavorDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "scc_region", Value: region, DataType: "string"},
		{Name: "cos_region", Value: region, DataType: "string"},
		{Name: "cos_instance_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_instance_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_workload_protection_instance_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_workload_protection_resource_key_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "scc_cos_bucket_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "scc_workload_protection_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "cos_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeInstances(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: instanceFlavorDir,
		Prefix:       "scc-upg",
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":                              options.Prefix,
		"resource_group_name":                 options.Prefix,
		"existing_kms_instance_crn":           permanentResources["hpcs_south_crn"],
		"kms_endpoint_type":                   "public",
		"provider_visibility":                 "public",
		"management_endpoint_type_for_bucket": "public",
	}

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

// A test to pass existing resources to the SCC instances DA
func TestRunExistingResourcesInstances(t *testing.T) {
	t.Parallel()

	// ------------------------------------------------------------------------------------
	// Provision COS, Sysdig and EN first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-ext-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources/instances"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()
	region := "us-south"

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {

		// ------------------------------------------------------------------------------------
		// Deploy SCC instances DA passing in existing COS instance, bucket, Sysdig and EN details
		// ------------------------------------------------------------------------------------

		options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: instanceFlavorDir,
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			Region:           region,
			TerraformVars: map[string]interface{}{
				"prefix":                              prefix,
				"cos_region":                          region,
				"scc_region":                          region,
				"resource_group_name":                 terraform.Output(t, existingTerraformOptions, "resource_group_name"),
				"use_existing_resource_group":         true,
				"existing_monitoring_crn":             terraform.Output(t, existingTerraformOptions, "monitoring_crn"),
				"existing_scc_cos_bucket_name":        terraform.Output(t, existingTerraformOptions, "bucket_name"),
				"existing_cos_instance_crn":           terraform.Output(t, existingTerraformOptions, "cos_crn"),
				"management_endpoint_type_for_bucket": "public",
				"provider_visibility":                 "public",
				"existing_en_crn":                     terraform.Output(t, existingTerraformOptions, "en_crn"),
				"en_source_name":                      prefix, // This name must be unique per SCC instance that is integrated with the Event Notifications instance.
			},
		})

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")

		// ------------------------------------------------------------------------------------
		// Deploy SCC instances DA passing in existing COS instance (not bucket), KMS key and Sysdig
		// ------------------------------------------------------------------------------------

		options2 := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: instanceFlavorDir,
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			TerraformVars: map[string]interface{}{
				"prefix":                              prefix,
				"cos_region":                          region,
				"scc_region":                          region,
				"resource_group_name":                 terraform.Output(t, existingTerraformOptions, "resource_group_name"),
				"use_existing_resource_group":         true,
				"existing_monitoring_crn":             terraform.Output(t, existingTerraformOptions, "monitoring_crn"),
				"existing_kms_instance_crn":           permanentResources["hpcs_south_crn"],
				"kms_endpoint_type":                   "public",
				"provider_visibility":                 "public",
				"existing_cos_instance_crn":           terraform.Output(t, existingTerraformOptions, "cos_crn"),
				"management_endpoint_type_for_bucket": "public",
			},
		})

		output2, err := options2.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output2, "Expected some output")

	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
