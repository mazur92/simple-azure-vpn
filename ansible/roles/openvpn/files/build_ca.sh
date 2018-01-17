#!/bin/bash
source vars
./clean-all
echo -ne '\n\n\n\n\n\n\n\n' | ./build-ca
./build-key-server --batch SimpleAzureVPN
./build-dh
openvpn --genkey --secret keys/ta.key