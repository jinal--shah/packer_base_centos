export AWS_ACCESS_KEY_ID?=
export AWS_SECRET_ACCESS_KEY?=
export AWS_REGION?=eu-west-1

## ami-30ff5c47 = Official CentOS6.x AMI
export AWS_SOURCE_AMI?=ami-30ff5c47
export AWS_INSTANCE_TYPE?=t2.small

export BUILD_ID?=$(shell date +%s)
export BUILDER?=amazon-ebs
export SHELL=/bin/bash
export BASE_AMI?=
export BASE_DOMAIN?=trainz.io

export SSH_KEYPAIR_NAME?=eurostar
export SSH_PRIVATE_KEY_FILE?=eurostar.pem
export SSH_USERNAME?=ec2-user

# These EUROSTAR_* vars must meet only use alphanumberics or underscores
# for their values.
export EUROSTAR_SERVICE_NAME?=enovation
export EUROSTAR_SERVICE_ROLE?=appsvr
export EUROSTAR_RELEASE_VERSION?=$(BUILD_ID)

export METRICS_REMOTE_HOST?=sa1.customeraccounts.eurostar.com
export METRICS_REMOTE_PORT?=2003

export ROLE?=app-server
export CODE_BRANCH?=enovation

export PUPPET_ROLE=$(ROLE)
export PUPPET_REPO?=https://github.com/ivangutev/eif_puppet.git
export PUPPET_BRANCH?=enovation
export PUPPET_DIR?=puppet
export PUPPET_ENVIRONMENT?=integration
export PUPPET_SERVICE?=enovation
export PUPPET_PRODUCT?=enovation

export PACKER?=$(shell which packer)
export PACKER_DEBUG?=#-debug
export PACKER_DIR?=./
export PACKER_LOG?=1
export PACKER_TEMPLATE_PUPPET?=$(PACKER_DIR)/002-generic-puppet-node.json

.PHONY: help
help: ## Run to show available make targets and descriptions
	@echo [INFO] Packer - Available make targets and descriptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: show_env
show_env: ## show me my environment
	@echo [INFO] EXPORTED ENVIRONMENT - AVAILABLE TO ALL TARGETS
	@env | sort | uniq

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
	if [[ "$(ROLE)" == "frontend" ]]; then aws s3 cp s3://enovation-fe/builds/latest/enovation_fe_latest.tar.gz frontend/ ; fi;
	rm -rf puppet; \
	git clone --branch $(PUPPET_BRANCH) $(PUPPET_REPO) puppet; \
	cd puppet; \
	librarian-puppet install; \

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
	  aws ec2 describe-images --region $(AWS_REGION) \
	    --filters 'Name=name,Values=eurostar-microservices-base-centos-6.x-puppet-3.8.2' \
	    --query 'Images[*].{ID:ImageId}' --output text | \
	    tee base_ami.id; \
	else \
	  echo "$(BASE_AMI)" > base_ami.id; \
	fi

