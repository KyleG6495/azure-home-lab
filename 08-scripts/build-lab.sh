#!/bin/bash
# build-lab.sh
# Builds the homelab network from nothing: resource group, virtual network,
# two subnets, a network security group with inbound rules, and the association
# between the NSG and the servers subnet.
#
# Usage: ./build-lab.sh <resource-group-name> <your-public-ip>
# Example: ./build-lab.sh rg-homelab-test 47.205.64.40
#
# Does not create VMs. Those are slow and billable; the network is the part
# worth automating.

set -e   # stop immediately if any command fails

RG="$1"
MYIP="$2"
LOCATION="eastus"

if [ -z "$RG" ] || [ -z "$MYIP" ]; then
  echo "Usage: ./build-lab.sh <resource-group-name> <your-public-ip>"
  exit 1
fi

echo "Creating resource group $RG..."
az group create --name "$RG" --location "$LOCATION" --output none

echo "Creating virtual network with the servers subnet..."
az network vnet create \
  --resource-group "$RG" \
  --name vnet-homelab \
  --address-prefix 10.0.0.0/16 \
  --subnet-name snet-servers \
  --subnet-prefix 10.0.1.0/24 \
  --output none

echo "Adding the clients subnet..."
az network vnet subnet create \
  --resource-group "$RG" \
  --vnet-name vnet-homelab \
  --name snet-clients \
  --address-prefix 10.0.2.0/24 \
  --output none

echo "Creating network security group..."
az network nsg create --resource-group "$RG" --name nsg-servers --output none

echo "Adding inbound rules for $MYIP..."
az network nsg rule create --resource-group "$RG" --nsg-name nsg-servers \
  --name Allow-RDP-Home --priority 100 --source-address-prefixes "$MYIP" \
  --destination-port-ranges 3389 --protocol Tcp --access Allow --output none

az network nsg rule create --resource-group "$RG" --nsg-name nsg-servers \
  --name Allow-SSH-Home --priority 110 --source-address-prefixes "$MYIP" \
  --destination-port-ranges 22 --protocol Tcp --access Allow --output none

az network nsg rule create --resource-group "$RG" --nsg-name nsg-servers \
  --name Allow-HTTP-Home --priority 120 --source-address-prefixes "$MYIP" \
  --destination-port-ranges 80 --protocol Tcp --access Allow --output none

echo "Attaching the NSG to the servers subnet..."
az network vnet subnet update \
  --resource-group "$RG" \
  --vnet-name vnet-homelab \
  --name snet-servers \
  --network-security-group nsg-servers \
  --output none

echo ""
echo "Done. Network built in resource group: $RG"
echo "To remove everything: az group delete --name $RG --yes --no-wait"
