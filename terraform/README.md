# Store Demo - Terraform

Terraform is used to provision a 18 node CockroachDB cluster across 3 geographically disperse US Data Centers and 2 cloud providers.  Again, the intent is to demonstrate survivability across Data Centers, Cloud Providers and the Continental U.S. [power transmission grid](https://en.wikipedia.org/wiki/Continental_U.S._power_transmission_grid).
* Data Center A - Azure's `eastus` region, zone `1` in Virginia on the Eastern Interconnection grid
* Data Center B - Azure's `eastus` region, zone `2` in Virginia on the Eastern Interconnection grid
* Data Center C - Google's `us-central1` region, zone `us-central1-a` in Iowa on the Eastern Interconnection grid
* Data Center D - Google's `us-central1` region, zone `us-central1-b` in Iowa on the Eastern Interconnection grid
* Data Center E - Google's `us-west2` region, zone `us-west2-a` in California on the Western Interconnection grid
* Data Center F - Google's `us-west2` region, zone `us-west2-b` in California on the Western Interconnection grid
 
## Prerequisites
All of my development was done on a Mac running the latest version of macOS.  Your mileage may vary on other platforms.  You will need to download and install the following.  For Google and Azure you will need an account and credentials.
* Homebrew - https://brew.sh/
* Terraform - https://www.terraform.io/downloads.html or `brew install terraform`
* Google Cloud SDK - https://cloud.google.com/sdk/docs/quickstart-macos or `brew cask install google-cloud-sdk`
* Azure CLI - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest or `brew install azure-cli`

Tested with...
```
Terraform v0.13.5
+ provider registry.terraform.io/hashicorp/azurerm v2.33.0
+ provider registry.terraform.io/hashicorp/google v3.44.0
+ provider registry.terraform.io/hashicorp/null v3.0.0
+ provider registry.terraform.io/hashicorp/random v3.0.0
```

## Building the Cluster
1) Create a Google Cloud [Service Account Key](https://cloud.google.com/docs/authentication/getting-started) and download it as a `.json` file called `gcp-account.json` and place it in this directory.

2) *Optional for Google:* If you have never used SSH to connect to a Google Cloud compute instance, you may need to run `gcloud compute config-ssh` to create the required SSH keys referenced by the variable `gcp_private_key_path` in [variables.tf](variables.tf).  See [here](see https://cloud.google.com/sdk/gcloud/reference/compute/config-ssh) for more details.  The username associated with this SSH key should be your local username.  Use this for the `gcp_user` variable below.

3) *Optional for Azure:* If you have never used SSH to connect to an `azure` compute instance, you may need to run `ssh-keygen -m PEM -t rsa -b 4096` to create the required `azure` SSH keys referenced by the variables `azure_private_key_path` and `azure_public_key_path` in [variables.tf](variables.tf).  See [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) for more details.  You can use `azureuser` as the `azure_user` variable below.

4) Create a file called `store-demo.tfvars` and place it in this directory.  Contents of the file must include the following required variables with values appropriate for your environment.  For additional configuration options see [variables.tf](variables.tf).
    ```hcl-terraform
    gcp_project_id = "your google project id"
    gcp_user = "user used to ssh into google instances"
    azure_user = "user used to ssh into azure instances"
    crdb_license_org = "crdb license org"
    crdb_license_key = "crdb license key"
    ```
 
5) Initialize Terraform
    ```bash
    terraform init -upgrade
    ```

6) Build the cluster
    ```bash
    ./apply.sh
    ```

    If everything is successful you should see a message like this in the console...
    ```text
    Apply complete! Resources: 146 added, 0 changed, 0 destroyed.
    ```
    *the number of resources added may be different*
7) Pick one of the public IP's listed above and visit the CockroachDB UI, `http://PICK_PUBLIC_IP_FROM_ABOVE:8080`


8) Destroy the cluster when you are finished
    ```bash
    ./destroy.sh
    ```
   
   If everything is successful you should see a message like this in the console...
   ```text
   Destroy complete! Resources: 146 destroyed.
   ```
   *the number of resources destroyed may be different*

## Other Helpful Commands

### Refresh State
```bash
./refresh.sh
```

### View Plan
```bash
./plan.sh
```

