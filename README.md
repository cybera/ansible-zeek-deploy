# Ansible Zeek Deployment
This is a small example of automating, or mostly automating, a Zeek deployment from one virtual machine onto another virtual machine. Not for Production. Refer to **Setup** for recommended deployment. The included playbooks will install an Ubuntu 22.04 compatible binary of Zeek, in addition to a few third party Zeek modules. The following modules are included:
 - https://github.com/cybera/zeek-sniffpass
## Setup
Recommended testing environment:
- One virtual machine to install Ansible and deploy the playbooks from; will be referred to as the `ansible-controller`.
- One virtual machine where we will deploy Zeek using Ansible. This will be known as the `zeek-instance`.
- The `ansible-controller` must be able to ssh to the `zeek-instance`.
- Both the `ansible-controller` and the `zeek-instance` must be able to `apt install` other packages from the internet.
## Building the Ansible Controller and Zeek Instance
Create a virtual machine that will be your `ansible-controller`, then go ahead and `git clone` this repo to that VM. Once this is done, `cd ansible_zeek_deploy` and then `mkdir keys` within. This `keys` directory will be used to store our ssh keypairs. Once the `keys` directory is made, `cd keys` and then use the following command to generate the zeek ssh key, with no password:
```
ansible-controller$ ssh-keygen -t ed25519 -N "" -f zeek_key
```
Once the ssh keypair are made, go back to the `ansible_zeek_deploy` directory and then execute `sudo bash ansible_deploy.sh` and let it run. It will install the necessary dependencies to run Ansible on your `ansible-controller`. 

The `ansible-controller` is now ready. Go make another virtual machine, which will be our `zeek-instance`. 
Once the `zeek-instance` virtual machine is created, do not update it. Do not install anything for now, just record the IP address or domain name you need to ssh to it from the `ansible-controller`.

With the `zeek-instance` now ready,  let's go back to the ssh keypair we made earlier on `ansible-controller`. Copy the `zeek_key.pub` contents and paste it all into the `/home/ubuntu/.ssh/authorized_keys` file on `zeek-instance`.

Once you have done this, go ahead and test the connection from your `ansible-controller` to your `zeek-instance`, to verify we're able to reach the `zeek-instance` from the `ansible-controller`:
```
ansible-controller$ ssh -i <Where/your/private/zeek_key/is/located ubuntu@<IP_addr_of_zeek_instance>
```
Once we've verified that we can reach the `zeek-instance` from the `ansible-controller`, we now need to modify our `inventory/zeek-instance` file on our `ansible-controller`. Replace `<IP4/6_ADDR or DOMAIN>` with either an IPv4, IPv6 or a domain for your test.
## Prepping to run the Playbooks
From the `ansible-controller`, go ahead and run the ssh-agent on your current session:
```
ansible-controller$ eval "$(ssh-agent)"
```
Then go ahead and add your zeek ssh key (Not your `.pub` key):
```
ansible-controller$ ssh-add <where/zeek_key/is/located>
```
Then you need to activate the Ansible venv, to begin running the playbooks:
```
ansible-controller$ source /opt/ansible/venv/bin/activate
```
## Running the Zeek Playbooks
Now from your `ansible-controller`, you can build the Zeek service on the `zeek-instance`:
```
$ ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_build.yml
```
After building Zeek, you may then configure zeek:
```
$ ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_configure.yml
```
And then once you're done with Zeek, you can teardown:
```
ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_teardown.yml
```
