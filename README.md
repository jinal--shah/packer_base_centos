# enovation_build_tools
Build pipeline tools for enovation to allow creating images and infrastructure.


## Packer
Packer is used to build role based images using puppet/shell provisioners

A base AMI is created to provide a fully patched AMI to reduce build time for the role based AMIs.

The role based AMIs use puppet and shell provisioners to install and configure images. Example roles like gateway, appserver, amq, glusterfs etc.


```
$ cd packer
$ make
[INFO] Packer - Available make targets and descriptions
base            Run packer build using defined variables to create patched base ami with puppet
build           Run packer build using defined variables (e.g. ROLE=gateway PACKER_DEBUG=-debug make build)
clone           Clone puppet repo
help            Run to show available make targets and descriptions
sshkeyfile      Symlink local sshkey to directory to use in Packer
validate        Run packer validate using defined variables

$ make clone build

$ ROLE=gateway PACKER_DEBUG=-debug make clone build
```

## Terraform
Terraform is used to create the infrastructure, from VPC, network, instances and peering.

Currently enovation has separate directories for the various servers:
- enovation/terraform/
- booking/terraform/
- payments/terraform/

Due to time scales there is some repetition in the code. The aim would be to split out into a modules so that common code can be shared.

[WARNING] The terraform state is being stored in S3. Before running terraform for the individual servers the remote state needs to be configured and retrieved.
```
$ export tag_environment=perf
$ export tag_service=enovation

$ terraform remote config \
  -backend=s3 \
  -backend-config="bucket=eurostar-terraform-state-${}" \
  -backend-config="key=${tag_environment}/vpc.tfstate" \
  -backend-config="region=eu-west-1" \
  -backend-config="encrypt=true" \
  -backend-config="access_key=AKXXX" \
  -backend-config="secret_key=YYY"
```

[OPTIONAL] Add variables and values to terraform.tfvars file that will be automtically read. Otherwise pass in values by exporting or inputing when terraform is run.

Plan, Build and Update:
```
$ terraform plan
$ terraform apply
```

Destroy:
```
$ terraform destroy
```


## Useful
List Instance IDs and Instance Names filtered by environment tag:
```
$ tag_environment=perf

$ aws ec2 describe-instances \
  --filter Name=instance-state-name,Values=running Name=tag:Environment,Values=${tag_environment} \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,NAME:Tags[?Key==`Name`].Value[]}' \
  --output text|sed 'N;s/\nNAME//'|sort -k2
```

