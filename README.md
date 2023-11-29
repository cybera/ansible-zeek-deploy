# Ansible Zeek Standalone Deployment
This is a small example of automating, or mostly automating, a Zeek Standalone deployment. Not for Production. The included playbooks will install an Ubuntu 22.04 compatible binary of Zeek, in addition to a third party Zeek module, with the ability to add more. The following module included:
 - https://github.com/cybera/zeek-sniffpass
## Recommended testing environment:
- One virtual machine to install Ansible and deploy the playbooks from; will be referred to as the `ansible-controller`.
- One virtual machine where we will deploy Zeek using Ansible. This will be known as the `zeek-instance`.
- The `ansible-controller` must be able to ssh to the `zeek-instance`.
- Both the `ansible-controller` and the `zeek-instance` must be able to `apt install` other packages from the internet.
## Building the Ansible Controller and Zeek Instance
Create a virtual machine that will be your `ansible-controller`, then `git clone` this repo to that VM. Once this is done, `cd ansible_zeek_deploy` and then `mkdir keys` within. This `keys` directory will be used to store our ssh keypairs. Once the `keys` directory is made, `cd keys` and then use the following command to generate the zeek ssh key, with no password:
```
ansible-controller$ ssh-keygen -t ed25519 -N "" -f zeek_key
```
Once the ssh keypair are made, go back to the `ansible_zeek_deploy` directory and then execute `sudo bash ansible_deploy.sh` and let it run. It will install the necessary dependencies to run Ansible on your `ansible-controller`.  Your `ansible-controller` is now ready. 

Go make another virtual machine, which will be our `zeek-instance`. 
Once the `zeek-instance` is created, do not update it and no not install anything for now, just record the IP address or domain name you need to ssh to it from the `ansible-controller`. The `zeek-instance` now ready.

Go back to the ssh keypair you made earlier on `ansible-controller`. Copy the `zeek_key.pub` contents and paste it all into the `/home/ubuntu/.ssh/authorized_keys` file on `zeek-instance`.

Once you have done this, go ahead and test the connection from your `ansible-controller` to your `zeek-instance`, to verify connectivity to the `zeek-instance` from the `ansible-controller`:
```
ansible-controller$ ssh -i <Where/your/private/zeek_key/is/located ubuntu@<IP_addr_of_zeek_instance>
```
On the `ansible-controller`, modify `inventory/zeek-instance` file and replace `<IP4/6_ADDR or DOMAIN>` with the same address you used earlier to ssh to the `zeek-instance`.
## Prepping the Playbooks
From the `ansible-controller`, run the ssh-agent:
```
ansible-controller$ eval "$(ssh-agent)"
```
Add your zeek ssh key (Not your `.pub` key):
```
ansible-controller$ ssh-add <where/zeek_key/is/located>
```
Activate the Ansible venv:
```
ansible-controller$ source /opt/ansible/venv/bin/activate
```
## Running the Playbooks
From `ansible-controller`, build Zeek on the `zeek-instance`:
```
ansible-controller$ ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_build.yml
```
Then configure zeek:
```
ansible-controller$ ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_configure.yml
```
And then once you're done with Zeek, you can teardown:
```
ansible-controller$ ansible-playbook -i inventories/zeek-instance plays/ansible_zeek_teardown.yml
```
