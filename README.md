# App Service Demo

This contains a simple project which deploys an App Service (on Linux or Windows) using an ARM or bicep template. The included GitHub workflow illustrates the process required to automatically deploy changes to the application to Azure. The workflow re-deploys the ARM template each time to ensure any changes to the infrastructure are applied. This also ensures that changes made outside of source control -- by team members or malicious actors -- are automatically reverted. In production environments, it's not uncommon to have a scheduled task to re-apply the infrastructure-as-code for this reason.

## Automated deployment

The workflow depends on specific variables being present. Configuring variables is covered in the [GitHub documentation](https://docs.github.com/en/actions/learn-github-actions/variables). The required variables:

| Variable             | Purpose                                                                                                                           |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| AZURE_WEBAPP_NAME    | The name of the web application. If this variable was not provided, a dynamic, unique name would be generated with `uniquestring`.|
| AZURE_RESOURCE_GROUP | The name of the resource group to use for the deployment.                                                                         |
| AZURE_LOCATION       | The Azure location to use for deploying the resources. Defaults to matching the resource group.                                   |

The workflow depends on Azure OIDC for authorizing the application and deploying resources. An application meeds to be created and registered in Azure Active Directory using the following steps:

1. Open Azure Active Directory's **App Registrations** blade.
2. Press **New registration**.
   - Specify any name. This name will also be the "user" that you will assign roles.
   - Select **Accounts in this organizational directory only (Single tenant)**
   - Redirect URI can be left blank
3. In the Application blade, choose **Certificates & Secrets**
4. Select **Federated Credentials** and choose **Add Credential**
   - For **Federated credential scenario**, choose **GitHub Actions deploying Azure resources** 
   - Enter the **Organization** and **Repository** associated with the credential.
   - Specify an **Entity Type** based on the job deploying the resource. If it's a 
     tag-triggered Action, select Tag. If it's branch triggered, select Branch. 
     For pull requests, select Pull Request. If the credential is being used by a
     job deploying to an Environment, you should use Environment.
   - Provide a name for this scenario and optionally provide a description.
   - Click **Add**
5. In the Overview blade, capture the **Application (Client) ID** and the **Directory (Tenant) ID**
6. From the appropriate Azure Resource Group (or the subscription), capture the **Subscription ID**.
7. In Azure, configure resources with appropriate RBAC permissions using the name of the application as the identity. For this sample, assign `Contributor` rights at the subscription level. This enables the creation and management of a resource group.
8. In GitHub, open your personal Settings, then open **Developer Settings** and select [**Personal access tokens**(https://github.com/settings/tokens). Create a token with the `repo` and `read:org`
9. In the GitHub repository, configure the following secrets with the values collected in steps 5,6 and 8:

   | Secret                | Value                                             |
   | --------------------- |    ---------------------------------------------- |
   | AZURE_CLIENT_ID       | Application (Client)    Id                        |
   | AZURE_TENANT_ID       | Azure AD directory (tenant)    identifier.        |
   | AZURE_SUBSCRIPTION_ID | The Azure subscription containing the resources.  |

- Automatically defaulting the deployment location to match the selected Resource Group
- Passing ARM functions that must be executed in the template for deployment (uniquestring) into the ARM template using a field value
- Implementing resource tags in the UI and Bicep

