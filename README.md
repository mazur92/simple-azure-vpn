# Simple Azure VPN
[![Build Status](https://travis-ci.org/mazur92/simple-azure-vpn.svg?branch=master)](https://travis-ci.org/mazur92/simple-azure-vpn)
## Prerequisites
* Terraform 0.10.8<
* Ansible 2.4<
* Microsoft Azure account (You may register at https://azure.microsoft.com/en-us/free/)
* Some OpenVPN client (eg. Tunnelblick for macOS)

## Note about operating systems

This utility was written on macOS and is intended to be used on *nix systems. It lacks Windows support (for now at least) in wrapper script (makevpn.sh). As such it is still pretty easy to do it on Windows, provided you have Ansible and Terraform installed and have your ssh key generated - you just need to manually modify variables.tf and main.yml in openvpn ansible role and then run terraform plan/apply + ansible-playbook.

## Azure authentication and authorization

To make things easier it's good to install azure-cli on your system. Here is how: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

Then login:
```
az login
```

Get your tenant and subscription id:
```
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```

Then create service principal for azure cli:

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR-SUBSCRIPTION-ID-GOES-HERE"
```

You should receive similar response:
```
{
  "appId": "a487e0c1-82af-47d9-9a0b-af184eb87646d",
  "displayName": "azure-cli-2018-01-22-20-26-18",
  "name": "azure-cli-2018-01-22-20-26-18",
  "password": {strong password},
  "tenant": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}
```
**IMPORTANT NOTICE: Save these details somewhere safe. Once they're gone from your terminal window you won't be able to retrieve client_secret and will need to regenerate keys if they're lost.**

* appID is your client_id
* password is your client_secret
* tenant is your tenant_id, but we got that earlier

## Wrapper script

Now that you have all the details needed, all you need to do is run makevpn.sh from the repo main directory. It will ask for some details, generate ssh keypair for connecting to your server, deploy infrastructure using Terraform, add your new server to your ssh config, provision with Ansible and copy clients configs over to your home directory.

You can also fill out all the details in batch_makevpn.sh and invoke both scripts like this to avoid step-by-step details filling:
```
./batch_makevpn.sh | ./makevpn.sh
```

## Clients regeneration

To regenerate (all) clients, enter ansible directory and run this command:
```
ansible-playbook vpn.yml -i inventory.yml --key-file=~/.ssh/azurevpn --tags=regenerate-clients
```

To regenerate (and/or create new) clients, enter ansible directory and run this command with required changes (note the --extra-vars parameter):
```
ansible-playbook vpn.yml -i inventory.yml --key-file=~/.ssh/azurevpn --tags=regenerate-clients --extra-vars='{"vpn_users": [client1, client_new]}'
```

## Note about VM size

Standard_B1s vm size is currently subject to Azure Free Trial and is free of charge for 750hr/mo for 12 months. That was the size of VM I was testing on.

## Note about transfer limits

Please be aware that currently Azure Free Trial allows **15GB** of transfer **out** (subject to change) per month for 12 months. Anything above will be charged.

## Note about hardening

The VPN server created here by default blocks ALL incoming connections, apart from SSH and OpenVPN. It's also configured to be automatically updated once in a while and fail2ban is installed. After that CIS role from Ansible Galaxy is run over the server to comply with standards.

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.