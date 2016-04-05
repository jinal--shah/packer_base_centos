AWS_ACCESS_KEY?=
AWS_SECRET_KEY?=
AWS_REGION?=eu-west-1
AWS_SOURCE_AMI?=
AWS_INSTANCE_TYPE?=
AWS_DEFAULT_REGION?=eu-west-1
AWS_DEFAULT_PROFILE?=eurostar

BUILD_ID?=$(shell date +%s)
BUILDER?=amazon-ebs
SHELL?=/bin/bash
BASE_AMI?=ami-a63d7ad1
BASE_DOMAIN?=local.

SSH_KEYPAIR_NAME?=eurostar
SSH_PRIVATE_KEY_FILE?=eurostar.pem
SSH_USERNAME?=ec2-user

ROLE?=app-server
CODE_BRANCH?=enovation
PUPPET_BRANCH?=enovation
PUPPET_DIR?=puppet
PUPPET_ENVIRONMENT?=integration
PUPPET_SERVICE?=enovation

TERRAFORM?=$(shell which terraform)

VAR_FILE=-var-file=$(PACKER_DIR)/default-variables.json

VARS=-var 'BUILD_ID=$(BUILD_NUMBER)' \
		 -var 'db_vpc_id=vpc-5b49433e' \
		 -var 'public_subnet_cidr_1b=10.38.128.192/26' \
		 -var "ami_appserver=ami-82c94df1" \
		 -var 'domain_name_servers=AmazonProvidedDNS' \
		 -var 'db_vpc_cidr=10.38.120.0/26' \
		 -var 'buildnum=11' \
		 -var 'aws_access_key=$(AWS_ACCESS_KEY_ID)' \
		 -var 'aws_secret_key=$(AWS_SECRET_ACCESS_KEY)' \
		 -var 'aws_key_path=~/.ssh/eurostar-aws-dev.pem' \
		 -var 'aws_key_name=eurostar' \
		 -var 'aws_region=eu-west-1' \
		 -var 'account=Enovation_Microservice' \
		 -var 'environment=integration' \
		 -var 'tag_environment=integration' \
		 -var 'tag_project=microservices' \
		 -var 'tag_role=microservices' \
		 -var 'tag_service=Enovation_Microservice' \
		 -var 'tag_db_role=enovation-db' \
		 -var 'tag_creator=terraform' \
		 -var 'tag_servicecriticality=Low' \
		 -var 'tag_supportcontact=Digital Systems' \
		 -var 'tag_department=Digital Systems' \
		 -var 'tag_environment=integration' \
		 -var 'rds_instance_name=enovation-integration' \
		 -var 'db_vpc_cidr=10.38.120.0/26' \
		 -var 'db_private_subnet_cidr_1a=10.38.120.0/28' \
		 -var 'database_name=enovation' \
		 -var 'db_username=enovationadmin' \
		 -var 'db_password=Enovation!' \
		 -var 'vpc_cidr=10.38.128.0/24' \
		 -var 'public_subnet_cidr_1a=10.38.128.128/26' \
		 -var 'private_subnet_cidr_1a=10.38.128.0/26' \
		 -var 'private_subnet_cidr_1b=10.38.128.64/26' \
		 -var 'aws_route53_zone_id=Z3RU84YBKRCIRB' \
		 -var 'ami_amq=ami-c849f6bb'



.PHONY: build
build:  ## Run packer build using defined variables (e.g. ROLE=gateway PACKER_DEBUG=-debug make build)
	${TERRAFORM} apply $(VARS)
