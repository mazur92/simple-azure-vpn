#!/bin/bash
# First argument - key/server name
source vars
./clean-all
echo -ne '\n\n\n\n\n\n\n\n' | ./build-ca
./build-key-server --batch ${1}
./build-dh
openvpn --genkey --secret keys/ta.key