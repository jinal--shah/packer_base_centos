AWS_ACCESS_KEY_ID?=
AWS_SECRET_ACCESS_KEY?=
AWS_REGION?=eu-west-1

## ami-30ff5c47 = Official CentOS6.x AMI
AWS_SOURCE_AMI?=ami-30ff5c47
AWS_INSTANCE_TYPE?=t2.small

BUILD_ID?=$(shell date +%s)
BUILDER?=amazon-ebs
SHELL=/bin/bash
BASE_AMI?=
BASE_DOMAIN?=trainz.io

SSH_KEYPAIR_NAME?=eurostar
SSH_PRIVATE_KEY_FILE?=eurostar.pem
SSH_USERNAME?=ec2-user

# These EUROSTAR_* vars must meet only use alphanumberics or underscores
# for their values.
EUROSTAR_SERVICE_NAME?=enovation
EUROSTAR_SERVICE_ROLE?=appsvr
EUROSTAR_RELEASE_VERSION?=$(BUILD_ID)

METRICS_REMOTE_HOST?=sa1.customeraccounts.eurostar.com
METRICS_REMOTE_PORT?=2003

ROLE?=app-server
CODE_BRANCH?=enovation

PUPPET_ROLE=$(ROLE)
PUPPET_REPO?=git@github.com:ivangutev/eif_puppet.git
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

.PHONY: help
help: ## Run to show available make targets and descriptions
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

.PHONY: clone
clone: ## Clone puppet repo
	rm -rf puppet; \
	git clone --branch $(PUPPET_BRANCH) $(PUPPET_REPO) puppet; \
	cd puppet; \
	librarian-puppet install; \
	if [[ "$(ROLE)" == "frontend" ]]; then aws s3 cp s3://enovation-fe/builds/latest/enovation_fe_latest.tar.gz frontend/ ; fi;

.PHONY: validate
validate: sshkeyfile baseami ## Run packer validate using defined variables
	$(eval BASE_AMI := $(shell cat base_ami.id))
	packer validate "$(PACKER_TEMPLATE_PUPPET)"

.PHONY: base
base: ## Run packer build using defined variables to create patched base ami with puppet
	PACKER_TEMPLATE_PUPPET=001-base-image.json $(MAKE) validate
	PACKER_TEMPLATE_PUPPET=001-base-image.json $(MAKE) build

.PHONY: build 
build: baseami validate ## Run packer build using defined variables (e.g. ROLE=gateway PACKER_DEBUG=-debug make build)
	$(eval BASE_AMI := $(shell cat base_ami.id))
	packer build $(PACKER_DEBUG) "$(PACKER_TEMPLATE_PUPPET)"

SHELL=/bin/bash
.PHONY: baseami
baseami:
	if [[ "x$(BASE_AMI)" == "x" ]]; then \
	  aws ec2 describe-images \
	    --filters 'Name=name,Values=eurostar-microservices-base-centos-6.x-puppet-3.8.2' \
	    --query 'Images[*].{ID:ImageId}' --output text | \
	    tee base_ami.id; \
	else \
	  echo "$(BASE_AMI)" > base_ami.id; \
	fi

