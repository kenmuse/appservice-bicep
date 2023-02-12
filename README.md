# App Service Demo

This contains a simple project which deploys an App Service (on Linux or Windows) using an ARM or bicep template. The included GitHub workflow illustrates the process required to automatically deploy changes to the application to Azure. The workflow re-deploys the ARM template each time to ensure any changes to the infrastructure are applied. This also ensures that changes made outside of source control -- by team members or malicious actors -- are automatically reverted. In production environments, it's not uncommon to have a scheduled task to re-apply the infrastructure-as-code for this reason.

## Manual process

This repository also demonstrates how to create a [custom GUI](./env/main-ui.json) for manual deployments. While manual deployments are not generally recommended, this one can be used to quickly spin up a Linux or Windows App Service and App Service Plan, pre-configured to support [run-from-package](https://learn.microsoft.com/en-us/azure/app-service/deploy-run-package)

[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkenmuse%2Fappservice-demo%2Fmain%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fkenmuse%2Fappservice-demo%2Fmain%2Fmain-ui.json)

