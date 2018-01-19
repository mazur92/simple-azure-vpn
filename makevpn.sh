#!/usr/bin/env sh
SAVPN_REGION=""
SAVPN_SUBSCRIPTION_ID="" 
SAVPN_CLIENT_ID=""
SAVPN_CLIENT_SECRET=""
SAVPN_TENANT_ID=""
SAVPN_VM_SIZE=""
SAVPN_ADMIN_USERNAME=""  
SAVPN_SSH_KEY=""
SAVPN_VM_PUBLIC_IP=""
SAVPN_KEY_COUNTRY=""

echo =================================
echo SimpleAzureVPN wrapper script
echo Version 0.1
echo =================================
echo Some basic stuff is needed to fill out templates.

cp terraform/variables.tf.tpl terraform/variables.tf
echo =================================
echo 'Please provide Azure region you wish to be in (eg. West Europe):'
read SAVPN_REGION
sed -i '' "s/region/region = \"$SAVPN_REGION\"/g" terraform/variables.tf
echo =================================
echo 'Please provide your Azure subscription id:'
read SAVPN_SUBSCRIPTION_ID
sed -i '' "s/subscription_id/subscription_id = \"$SAVPN_SUBSCRIPTION_ID\"/g" terraform/variables.tf
echo =================================
echo 'Please provide your Azure client id:'
read SAVPN_CLIENT_ID
sed -i '' "s/client_id/client_id = \"$SAVPN_CLIENT_ID\"/g" terraform/variables.tf
echo =================================
echo 'Please provide your Azure client secret:'
read SAVPN_CLIENT_SECRET
sed -i '' "s/client_secret/client_secret = \"$SAVPN_CLIENT_SECRET\"/g" terraform/variables.tf
echo =================================
echo 'Please provide your Azure tenant id:'
read SAVPN_TENANT_ID
sed -i '' "s/tenant_id/tenant_id = \"$SAVPN_TENANT_ID\"/g" terraform/variables.tf
echo =================================
echo 'Please provide size for VM (eg. Standard_B1s)'
echo 'NOTICE: This is region dependant'
read SAVPN_VM_SIZE
sed -i '' "s/vm_size/vm_size = \"$SAVPN_VM_SIZE\"/g" terraform/variables.tf
echo =================================
echo 'Please provide admin username for the VM:'
read SAVPN_ADMIN_USERNAME
sed -i '' "s/admin_username/admin_username = \"$SAVPN_ADMIN_USERNAME\"/g" terraform/variables.tf
echo =================================
echo 'Please provide SSH public key to be used for admin login:'
read SAVPN_SSH_KEY
sed -i '' "s|ssh_key|ssh_key = \"$SAVPN_SSH_KEY\"|g" terraform/variables.tf
echo =================================
echo "Terraform will now attempt to create infrastructure."
terraform fmt terraform/variables.tf || exit 1
cd terraform
terraform plan -out vpn_infra_plan || exit 1
terraform apply "vpn_infra_plan" || exit 1
SAVPN_VM_PUBLIC_IP=$(terraform output vpn-machine-ip)
echo "Infrastructure created."
cd ../ansible
echo =================================
echo "To setup OpenVPN we need some information for certificate generation."
