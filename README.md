# foundryvtt-azure

[![deploy-foundryvtt](https://github.com/PlagueHO/foundryvtt-azure/actions/workflows/deploy-foundryvtt.yml/badge.svg)](https://github.com/PlagueHO/foundryvtt-azure/actions/workflows/deploy-foundryvtt.yml)

Deploy your own [Foundry Virtual Table Top](https://foundryvtt.com/) server (that you've purchased a license for) to Azure Container Instances, using Azure Bicep and GitHub Actions.

The project uses GitHub actions to deploy the resources to Azure using the [GitHub Action for Azure Resource Manager (ARM) deployment task](https://github.com/Azure/arm-deploy) and [Azure Bicep](https://aka.ms/Bicep).

This repository will deploy a Foundry Virtual Table top using various different Azure architectures to suit your requirements. The compute and storage is separated into different services to enable update and redeployment of the server without loss of the Foundry VTT data.

> IMPORTANT NOTE: This project has been to use Azure AD Workload Identity for the workflow to connect to Azure. Please see [Configuring Workload Identity Federation for GitHub Actions workflow](#configuring-workload-identity-federation-for-github-actions-workflow) for more information.

> IMPORTANT NOTE: You must have a valid [Foundry VTT license](https://foundryvtt.com/) attached to your account. If you don't have one, you can [buy one here](https://foundryvtt.com/purchase/).

## Azure Container Instances with Azure Files

This method will deploy an [Azure Container Instance](https://learn.microsoft.com/azure/container-instances/container-instances-overview) and attach an Azure Storage account with an SMB share for persistent storage.

It uses the `felddy/foundryvtt:release` container image from Docker Hub. The source and documentation for this container image can be found [here](https://github.com/felddy/foundryvtt-docker). It will use your Foundry VTT username and password to download the Foundry VTT application files and register it with your license key.

The following variables should be configured in the repository to define the region to deploy to and the storage and container configuration:

- `TYPE`: Should be set to `ACI` to deploy an Azure Container Instance.
- `LOCATION`: The Azure region to deploy the resources to. For example, `AustraliaEast`.
- `BASE_RESOURCE_NAME`: The base name that will prefixed to all Azure resources deployed to ensure they are unique. For example, `myfvtt`.
- `RESOURCE_GROUP_NAME`: The name of the Azure resource group to create and add the resources to. For example, `myfvtt-rg`.
- `STORAGE_CONFIGURATION`: The configuration of the Azure Storage SKU to use for storing Foundry VTT user data. Must be one of `Premium_100GB` or `Standard_100GB`.
- `CONTAINER_CONFIGURATION`: The configuration of the Azure Container Instance for running the Foundry VTT server. Must be one of `Small`, `Medium` or `Large`.

The following GitHub Secrets need to be defined to ensure that resource names for Storage Account and Container DNS are globally unique and provide access to your Azure subscription for deployment:

- `AZURE_CLIENT_ID`: The Application (Client) ID of the Service Principal used to authenticate to Azure. This is generated as part of configuring Workload Identity Federation.
- `AZURE_TENANT_ID`: The Tenant ID of the Service Principal used to authenticate to Azure.
- `AZURE_SUBSCRIPTION_ID`: The Subscription ID of the Azure Subscription to deploy to.
- `BASE_RESOURCE_NAME`: The base name that will prefixed to all Azure resources deployed to ensure they are unique. For example, `myfvtt`.
- `RESOURCE_GROUP_NAME`: The name of the Azure resource group to create and add the resources to. For example, `myfvtt-rg`.
- `FOUNDRY_USERNAME`: Your Foundry VTT username. This is used by the `felddy/foundryvtt:release` container image.
- `FOUNDRY_PASSWORD`: Your Foundry VTT password. This is used by the `felddy/foundryvtt:release` container image.
- `FOUNDRY_ADMIN_KEY`: The admin key to set Foundry VTT up with. This will be the administrator password you log into the Foundry VTT server with.

These values should be kept secret and care taken to ensure they are not shared with anyone.

Your secrets should look like this:
![Example of GitHub Secrets](/images/github-secrets-example.png)

## Configuring Workload Identity Federation for GitHub Actions workflow

Customize and run this code in Azure Cloud Shell to create the credential for the GitHub workflow to use to deploy to Azure.
[Workload Identity Federation](https://learn.microsoft.com/azure/active-directory/develop/workload-identity-federation) will be used by GitHub Actions to authenticate to Azure.

```powershell
$credentialname = '<The name to use for the credential & app>' # e.g., github-dsrfoundryvtt-workflow
$application = New-AzADApplication -DisplayName $credentialname
$policy = "repo:<your GitHub user>/<your GitHub repo>:ref:refs/heads/main" # e.g., repo:PlagueHO/foundryvtt-azure:ref:refs/heads/main
$subscriptionId = '<your Azure subscription>'

New-AzADAppFederatedCredential `
    -Name $credentialname `
    -ApplicationObjectId $application.Id `
    -Issuer 'https://token.actions.githubusercontent.com' `
    -Audience 'api://AzureADTokenExchange' `
    -Subject $policy
New-AzADServicePrincipal -AppId $application.AppId

New-AzRoleAssignment `
  -ApplicationId $application.AppId `
  -RoleDefinitionName Contributor `
  -Scope "/subscriptions/$subscriptionId" `
  -Description "The GitHub Actions deployment workflow for Foundry VTT."
```

To learn how to configure Workload Identity Federation with GitHub Actions, see [this Microsoft Learn Module](https://learn.microsoft.com/training/modules/authenticate-azure-deployment-workflow-workload-identities).
Please see [this document](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure) for more information on Workload Identities.
