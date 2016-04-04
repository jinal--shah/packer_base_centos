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
PUPPET_PRODUCT?=enovation

PACKER?=$(shell which packer)
PACKER_DEBUG?=#-debug
PACKER_DIR?=./
PACKER_LOG?=1
PACKER_TEMPLATE_PUPPET?=$(PACKER_DIR)/002-generic-puppet-node.json

# default vars file to pass to packer
VAR_FILE=-var-file=$(PACKER_DIR)/default-variables.json

# custom vars to pass to packer
VARS=-var 'base_ami=$(BASE_AMI)' \
     -var 'base_domain=$(BASE_DOMAIN)' \
     -var 'build_id=$(BUILD_ID)' \
     -var 'code_branch=$(CODE_BRANCH)' \
     -var 'puppet_branch=$(PUPPET_BRANCH)' \
     -var 'puppet_dir=$(PUPPET_DIR)' \
     -var 'puppet_environment=$(PUPPET_ENVIRONMENT)' \
     -var 'puppet_role=$(ROLE)' \
     -var 'puppet_repo=$(PUPPET_REPO)' \
     -var 'puppet_product=$(PUPPET_PRODUCT)' \
     -var 'puppet_service=$(PUPPET_SERVICE)' \
     -var 'aws_access_key=$(AWS_ACCESS_KEY)' \
     -var 'aws_secret_key=$(AWS_SECRET_KEY)' 


.PHONY: help
help:
	@echo [INFO] Packer - Available make targets and descriptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: sshkeyfile
sshkeyfile: ## Symlink local sshkey to directory to use in Packer
	@if [ -f ./$(SSH_PRIVATE_KEY_FILE) ]; \
	  then echo "[INFO] Found sshkey: ./$(SSH_PRIVATE_KEY_FILE)"; \
	elif [ -f ~/.ssh/$(SSH_PRIVATE_KEY_FILE) ]; \
	  then echo "[INFO] Found sshkey creating symlink: ~/.ssh/$(SSH_PRIVATE_KEY_FILE)"; \
	    ln -sf ~/.ssh/$(SSH_PRIVATE_KEY_FILE) ./$(SSH_PRIVATE_KEY_FILE); \
	else \
          echo "\033[0;31m[ERROR] Create a copy of sshkey in current directory (or symlink): e.g ./$(SSH_PRIVATE_KEY_FILE)\e[0m\n"; exit 1; \
	fi;

.PHONY: validate
validate: sshkeyfile ## Run packer validate using defined variables
	packer validate \
	  $(VAR_FILE) \
	  $(VARS) \
	  "$(PACKER_TEMPLATE_PUPPET)"

.PHONY: build 
build: validate ## Run packer build using defined variables (e.g. ROLE=gateway PACKER_DEBUG=-debug make build)
	packer build $(PACKER_DEBUG) \
	  $(VAR_FILE) \
	  $(VARS) \
	  "$(PACKER_TEMPLATE_PUPPET)"

