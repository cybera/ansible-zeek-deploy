#!/bin/bash

apt update && sudo apt upgrade
apt install -y python3-pip
apt install -y build-essential python3-dev python3 python3-venv
mkdir -p /opt/ansible
python3 -m venv /opt/ansible/venv
source /opt/ansible/venv/bin/activate
pip3 install pip
pip3 install -U pip --target /opt/ansible/venv/lib64/python3/site-packages/
pip3 install ansible
