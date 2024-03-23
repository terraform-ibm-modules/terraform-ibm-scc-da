# Security and Compliance Center Workload Protection Agent solution

This solution supports installing and configuring [IBM Cloud Security and Compliance Center Workload Protection agent](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started). It uses [sysdig-deploy charts](https://github.com/sysdiglabs/charts/tree/master/charts/sysdig-deploy) which deploys the following components into your cluster:
- Agent
- Node Analyzer
- KSPM Collector

This solution will deploy and configure the Workload Protections components in an existing cluster to an existing IBM Cloud Security and Compliance Center Workload Protection instance.

![scc-wp](https://github.com/terraform-ibm-modules/terraform-ibm-scc-da/blob/main/reference-architecture/scc-wp-agent.svg)