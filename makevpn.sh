#!/usr/bin/env bash
echo =================================
echo SimpleAzureVPN wrapper script
echo Version 0.5
echo =================================
echo Some basic stuff is needed to fill out templates.

source batch_makevpn.sh
ROOT_SCRIPT_DIR=$(pwd)

cp terraform/variables.tf.tpl terraform/variables.tf
echo =================================
echo 'Please provide Azure region you wish to be in (eg. West Europe):'
if [ -z "$SAVPN_REGION" ]; then
    read SAVPN_REGION
    if [ -z "$SAVPN_REGION" ]; then
        echo "SAVPN_REGION is empty!"
        exit -1
    fi
else
    echo $SAVPN_REGION
    sed -i '' "s/region/region = \"$SAVPN_REGION\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide your Azure subscription id:'
if [ -z "$SAVPN_SUBSCRIPTION_ID" ]; then    
    read SAVPN_SUBSCRIPTION_ID
    if [ -z "$SAVPN_SUBSCRIPTION_ID" ]; then
        echo "SAVPN_SUBSCRIPTION_ID is empty!"
        exit -1
    fi
else
    echo $SAVPN_SUBSCRIPTION_ID
    sed -i '' "s/subscription_id/subscription_id = \"$SAVPN_SUBSCRIPTION_ID\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide your Azure client id:'
if [ -z "$SAVPN_CLIENT_ID" ]; then
    read SAVPN_CLIENT_ID
    if [ -z "$SAVPN_CLIENT_ID" ]; then
        echo "SAVPN_CLIENT_ID is empty!"
        exit -1
    fi    
else
    echo $SAVPN_CLIENT_ID
    sed -i '' "s/client_id/client_id = \"$SAVPN_CLIENT_ID\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide your Azure client secret:'
if [ -z "$SAVPN_CLIENT_SECRET" ]; then
    read SAVPN_CLIENT_SECRET
    if [ -z "$SAVPN_CLIENT_SECRET" ]; then
        echo "SAVPN_CLIENT_SECRET is empty!"
        exit -1
    fi
else
    echo $SAVPN_CLIENT_SECRET
    sed -i '' "s/client_secret/client_secret = \"$SAVPN_CLIENT_SECRET\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide your Azure tenant id:'
if [ -z "$SAVPN_TENANT_ID" ]; then
    read SAVPN_TENANT_ID
    if [ -z "$SAVPN_TENANT_ID" ]; then
        echo "SAVPN_TENANT_ID is empty!"
        exit -1
    fi
else
    echo $SAVPN_TENANT_ID
    sed -i '' "s/tenant_id/tenant_id = \"$SAVPN_TENANT_ID\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide size for VM (eg. Standard_B1s)'
echo 'NOTICE: This is region dependant'
if [ -z "$SAVPN_VM_SIZE" ]; then
    read SAVPN_VM_SIZE
    if [ -z "$SAVPN_VM_SIZE" ]; then
        echo "SAVPN_VM_SIZE is empty!"
        exit -1
    fi
else
    echo $SAVPN_VM_SIZE
    sed -i '' "s/vm_size/vm_size = \"$SAVPN_VM_SIZE\"/g" terraform/variables.tf
fi
echo =================================
echo 'Please provide admin username for the VM:'
if [ -z "$SAVPN_ADMIN_USERNAME" ]; then
    read SAVPN_ADMIN_USERNAME
    if [ -z "$SAVPN_ADMIN_USERNAME" ]; then
        echo "SAVPN_ADMIN_USERNAME is empty!"
        exit -1
    fi
else
    echo $SAVPN_ADMIN_USERNAME
    sed -i '' "s/admin_username/admin_username = \"$SAVPN_ADMIN_USERNAME\"/g" terraform/variables.tf
fi
echo =================================
echo 'A SSH key will be generated for your admin user and placed in ~/.ssh/azurevpn'
echo n | ssh-keygen -t rsa -b 4096 -f ~/.ssh/azurevpn -N ''
SAVPN_SSH_KEY=$(cat ~/.ssh/azurevpn.pub)
if [ -z "$SAVPN_SSH_KEY" ]; then
    echo "SAVPN_SSH_KEY is empty!"
    exit -1
else
    echo $SAVPN_SSH_KEY
    sed -i '' "s|ssh_key|ssh_key = \"$SAVPN_SSH_KEY\"|g" terraform/variables.tf
fi
cd $ROOT_SCRIPT_DIR/ansible/roles/openvpn/defaults
cp main.yml.tpl main.yml
if [ -z "$SAVPN_ADMIN_USERNAME" ]; then
    echo "SAVPN_ADMIN_USERNAME is empty!"
    exit -1
else
    echo $SAVPN_ADMIN_USERNAME
    sed -i '' "s/admin_user:/admin_user: \"$SAVPN_ADMIN_USERNAME\"/g" main.yml
fi
echo =================================
echo "To setup OpenVPN we need some information for certificate generation."
echo "Country to put in cert (eg. PL, DE, etc.):"
if [ -z "$SAVPN_KEY_COUNTRY" ]; then
    read SAVPN_KEY_COUNTRY
    if [ -z "$SAVPN_KEY_COUNTRY" ]; then
        echo "SAVPN_KEY_COUNTRY is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_COUNTRY
    sed -i '' "s/key_country:/key_country: \"$SAVPN_KEY_COUNTRY\"/g" main.yml
fi
echo =================================
echo "Province to put in cert:"
if [ -z "$SAVPN_KEY_PROVINCE" ]; then
    read SAVPN_KEY_PROVINCE
    if [ -z "$SAVPN_KEY_PROVINCE" ]; then
        echo "SAVPN_KEY_PROVINCE is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_PROVINCE
    sed -i '' "s/key_province:/key_province: \"$SAVPN_KEY_PROVINCE\"/g" main.yml
fi
echo =================================
echo "City to put in cert:"
if [ -z "$SAVPN_KEY_CITY" ]; then
    read SAVPN_KEY_CITY
    if [ -z "$SAVPN_KEY_CITY" ]; then
        echo "SAVPN_KEY_CITY is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_CITY
    sed -i '' "s/key_city:/key_city: \"$SAVPN_KEY_CITY\"/g" main.yml
fi
echo =================================
echo "Organization to put in cert:"
if [ -z "$SAVPN_KEY_ORG" ]; then
    read SAVPN_KEY_ORG
    if [ -z "$SAVPN_KEY_ORG" ]; then
        echo "SAVPN_KEY_ORG is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_ORG
    sed -i '' "s/key_org:/key_org: \"$SAVPN_KEY_ORG\"/g" main.yml
fi
echo =================================
echo "E-mail address to put in cert:"
if [ -z "$SAVPN_KEY_EMAIL" ]; then
    read SAVPN_KEY_EMAIL
    if [ -z "$SAVPN_KEY_EMAIL" ]; then
        echo "SAVPN_KEY_EMAIL is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_EMAIL
    sed -i '' "s/key_email:/key_email: \"$SAVPN_KEY_EMAIL\"/g" main.yml
fi
echo =================================
echo "Organizational Unit to put in cert (can be whatever really, eg. your name):"
if [ -z "$SAVPN_KEY_OU" ]; then
    read SAVPN_KEY_OU
    if [ -z "$SAVPN_KEY_OU" ]; then
        echo "SAVPN_KEY_OU is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_OU
    sed -i '' "s/key_ou:/key_ou: \"$SAVPN_KEY_OU\"/g" main.yml
fi
echo =================================
echo "Name to put in cert (can be whatever really, eg. SimpleAzureVPN, myazurevpn etc.):"
if [ -z "$SAVPN_KEY_NAME" ]; then
    read SAVPN_KEY_NAME
    if [ -z "$SAVPN_KEY_NAME" ]; then
        echo "SAVPN_KEY_NAME is empty!"
        exit -1
    fi
else
    echo $SAVPN_KEY_NAME
    sed -i '' "s/key_name:/key_name: \"$SAVPN_KEY_NAME\"/g" main.yml
fi
echo =================================
echo vpn_users: >> main.yml
echo -e \
"Provide list of VPN users that you want to generate configs for.\n\
Usernames should be separated by spaces."
if [ -z "$SAVPN_VPN_USERS" ]; then
    read SAVPN_VPN_USERS
    if [ -z "$SAVPN_VPN_USERS" ]; then
        echo "SAVPN_VPN_USERS is empty!"
        exit -1
    fi
else
    for vpn_user in $SAVPN_VPN_USERS; 
    do
        echo "Config will be generated for user: $vpn_user"
        printf "  - $vpn_user\n" >> main.yml
    done    
fi

# Spin up infrastructure
cd $ROOT_SCRIPT_DIR
echo =================================
echo "Terraform will now attempt to create infrastructure."
terraform fmt terraform/variables.tf || exit 1
cd $ROOT_SCRIPT_DIR/terraform
terraform init
terraform plan -out vpn_infra_plan || exit 1
terraform apply "vpn_infra_plan" || exit 1
SAVPN_VM_PUBLIC_IP=$(terraform output vpn-machine-ip)
echo =================================
echo "Creating Ansible inventory file"
if [ -z "$SAVPN_VM_PUBLIC_IP" ]; then
    echo "SAVPN_VM_PUBLIC_IP is empty!"
    exit -1
else
    echo $SAVPN_VM_PUBLIC_IP
    cd $ROOT_SCRIPT_DIR/ansible/roles/openvpn/defaults
    sed -i '' "s/vm_public_ip:/vm_public_ip: \"$SAVPN_VM_PUBLIC_IP\"/g" main.yml
    cd $ROOT_SCRIPT_DIR/ansible
    cat > inventory.yml << EOF
---
all:
  hosts:
    $SAVPN_VM_PUBLIC_IP
EOF
fi
cd $ROOT_SCRIPT_DIR/terraform
echo =================================
echo "Infrastructure created."
rm vpn_infra_plan
echo =================================
if [ ! -f ~/.ssh/config ]; then
    touch ~/.ssh/config
fi
grep myvpn.azure ~/.ssh/config 2>&1 > /dev/null
if [ $? -ne 1 ];
then
    echo "Replacing remote host 'myvpn.azure' in ssh config"
    SAVPN_OLDIP=$(grep -v -A1 myvpn.azure ~/.ssh/config | head -1 | awk {'print $2'})
    sed -i '' "s/Hostname $SAVPN_OLDIP/Hostname $SAVPN_VM_PUBLIC_IP/g" ~/.ssh/config
else
    echo "Adding remote host as 'myvpn.azure' to ssh config in ~/.ssh/config"
    cat >> ~/.ssh/config << EOF
Host myvpn.azure
    Hostname $SAVPN_VM_PUBLIC_IP
    IdentityFile ~/.ssh/azurevpn
EOF
fi

# Provision with ansible
echo =================================
echo "Waiting some time to let server become available."
sleep 15
echo =================================
ssh-keyscan $SAVPN_VM_PUBLIC_IP 2>&1 | grep ecdsa >> ~/.ssh/known_hosts
ansible-galaxy install florianutz.Ubuntu1604-CIS
ansible-playbook $ROOT_SCRIPT_DIR/ansible/vpn.yml --inventory $ROOT_SCRIPT_DIR/ansible/inventory.yml --key-file=~/.ssh/azurevpn || exit 1
echo 'Config files will be placed in your home directory in ovpn_configs subdirectory.'
mkdir ~/ovpn_configs 2>/dev/null
mkdir -p /tmp/ovpn_configs/$SAVPN_VM_PUBLIC_IP/home/$SAVPN_ADMIN_USERNAME/client-configs/files/ 2>/dev/null
for vpn_user in $SAVPN_VPN_USERS; 
do
    cp /tmp/ovpn_configs/$SAVPN_VM_PUBLIC_IP/home/$SAVPN_ADMIN_USERNAME/client-configs/files/$vpn_user.ovpn ~/ovpn_configs/$vpn_user.ovpn
done
echo 'All done!'
echo 'You can access your VM via ssh: ssh myvpn.azure'


