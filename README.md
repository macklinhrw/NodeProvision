Note: Currently only provisions apache.

# Introduction

This is a repo of scripts designed to set up number of client droplets, and to run an ansible playbook
to provision Nginx to each in preparation to run a NodeJS server.

Each droplet is configured to use Ubuntu-20-04-x64, other configurations can be found by reviewing the `main.tf` file.

# Use

Make sure terraform is installed on your system and open a terminal in the repo directory.

First, create a `terraform.tfvars` file with the required variables (empty vars in the `main.tf` file). Otherwise,
you can enter them manually when following the next step.

Run:

`terraform apply`

Once prompted, type yes after reviewing the information terraform shows.

Terraform will provision the workstation PC with an ansible installation, ssh keys, as well as an ansible playbook (specified in `terraform.tfvars`). Then, it will run the ansible playbook to start provisioning Nginx.
