How to use Terraform, Packer and Ansible with DigitalOcean
==================

This is an example of how to use open source tools to provisioning and configuring DigitalOcean resources.

You can use this example to create a managed MySQL DB using Terraform, create and configure a Wordpress image with Packer and Ansible, and create a Droplet from that image in NYC3.

Requirements
------------

-	Terraform
-	Ansible
-	Packer

Building The Tutorial
---------------------

Clone repository to the machine you will run the tutorial from:

```sh
git clone https://github.com/diogoaav/packer-ansible-terraform-do.git
```

1- Creating the Managed DB with Terraform
---------------------

Enter the terraform-db directory and create a terraform.tfvars file and include your DO token:

```sh
cd packer-ansible-terraform-do/terraform-db
export DIGITALOCEAN_TOKEN="YOUR_DO_TOKEN"
```

Initiate Terraform and apply the config, this command will provision the DB in aproximately 5 min.

```sh
terraform init
terraform apply -var "do_token=${DIGITALOCEAN_TOKEN}"
```

After terraform succesfully deploy the MySQL DB, get the DB connections details with the command below:

```sh
terraform state show digitalocean_database_cluster.mysql_cluster
```

2- Creating the Wordpress image with Packer and Ansible
---------------------

In this step, we will use packer to create a wordpress image that will be used by Terraform later. Packer create a droplet, uses Ansible provisioner to install and configure relevant packages (PHP, Apache, Wordpress). You can check the Ansible playbook at /wordpress/playbook.yml.

Edit the Ansible playbook variable file in the wordpress/vars folder and include your managed DB details:

```sh
cd ../wordpress/vars
vim default.yaml
```

```sh
#MySQL Settings
mysql_db: "defaultdb"
mysql_user: "doadmin"
mysql_password: "YOUR_PASSWORD"
mysql_host: "YOUR_DB_URL:25060"
```

Go to the packer folder and create a variables.auto.pkrvars.hcl file and include your API token:

```sh
cd ../../packer
echo 'api_token = "YOUR_API_TOKEN"' > variables.auto.pkrvars.hcl
```

Execute packer, make sure you are in the same directory as the .hcl files:

```sh
packer init .
packer build .
```

Packer will take a few minutes to create a droplet, apply the terraform configuration using the Ansible provisioner, shutdown the droplet and creating a new image from that droplet.

Make sure you save the snapshot ID, that will be used to create the droplet in the next step.

3- Starting a new droplet from the image with Terraform
---------------------

Enter the terraform-droplet directory and create a terraform.tfvars file and include your DO token:

```sh
cd ../terraform-compute
```

Update you main.tf file with the correct snapshot id created in the previous step:

```sh
vim main.tf
```

```sh
# Create Droplet from snapshot
resource "digitalocean_droplet" "wordpress" {
  name    = "droplet-wordpress"
  region  = "nyc3"
  image   = "MY-SNAPSHOT-ID"
  size    = "s-1vcpu-1gb"
  backups = false
  ipv6    = true

}
```

Execute terraform:

```sh
terraform init
terraform apply -var "do_token=${DIGITALOCEAN_TOKEN}"
```

4- Teardown instructions
---------------------

```sh
terraform destroy -var "do_token=${DIGITALOCEAN_TOKEN}"
```

```sh
cd ../terraform-db
terraform destroy -var "do_token=${DIGITALOCEAN_TOKEN}"
```