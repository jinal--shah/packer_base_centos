# vim: ts=4 st=4 sr noet smartindent:
#
MANDATORY_VARS=           \
	AMI_NAME              \
	AWS_ACCESS_KEY_ID     \
	AWS_INSTANCE_TYPE     \
	AWS_REGION            \
	AWS_SECRET_ACCESS_KEY \
	AMI_SOURCE_ID         \
	BUILD_GIT_BRANCH      \
	BUILD_GIT_ORG         \
	BUILD_GIT_REPO        \
	BUILD_GIT_SHA         \
	BUILD_TIME            \
	PACKER_DIR

# ### CONSTANTS (not user-defineable)
# SSH_PRIVATE_KEY_FILE ... for build this is the AWS dev account's 'eurostar' key
#
AMI_PREVIOUS_SOURCES=
GIT_SHA_LEN=8
PACKER_JSON=packer.json
export AMI_PREFIX=eurostar_aws
export AMI_DESC_TXT=yum updates;ec2-user;permissive settings;awscli;cob;basic ops pkgs
export AMI_OS=centos
export AMI_OS_RELEASE=6.5
export AMI_SOURCE_FILTER=aws-marketplace/CentOS 6 x86_64*EBS*HVM*
export SHELL=/bin/bash
export SSH_KEYPAIR_NAME=eurostar
export SSH_PRIVATE_KEY_FILE=eurostar.pem
export SSH_USERNAME=root

# ### VARS (user-defineable)
# AMI_SOURCE_ID: ami that this new one builds on, determined by make
# PACKER_LOG: set to 1 for verbose - but the security-conscious be warned:
#             this will log all env var values including aws access creds ...
# PACKER_DEBUG: set to -debug for breakpoint mode. BUT, BUT, BUT ...
#               THERE IS A BUG IN PACKER 0.10.0 - DEBUG WILL HANG
#
export AWS_ACCESS_KEY_ID?=
export AWS_INSTANCE_TYPE?=t2.small
export AWS_REGION?=eu-west-1
export AWS_SECRET_ACCESS_KEY?=
export PACKER_DEBUG=
export PACKER_LOG?=
export PACKER_DIR?=./

# ### GENERATED VARS: determined by make based on other values.
# AMI_NAME : must be unique in AWS account, so we can locate it unambiguously.
# BUILD_GIT_*: used to AWS-tag the built AMI, and generate its unique name
#              so we can trace its providence later.
#
# ... to rebuild using same version of tools, we can't trust the git tag
# but the branch, sha and repo, because git tags are mutable and movable.
export BUILD_GIT_TAG?=
export BUILD_GIT_BRANCH=$(shell git describe --contains --all HEAD)
export BUILD_GIT_SHA=$(shell git rev-parse --short=$(GIT_SHA_LEN) --verify HEAD)
export BUILD_GIT_REPO=$(shell   \
	git remote show -n origin   \
	| grep '^ *Push *'          \
	| awk {'print $$NF'}        \
)
export BUILD_GIT_ORG=$(shell \
	echo $(BUILD_GIT_REPO)   \
	| sed -e 's!.*[:/]\([^/]\+\)/.*!\1!' \
)

AMI_NAME_GIT_INFO=$(BUILD_GIT_BRANCH)-$(BUILD_GIT_SHA)

export BUILD_TIME=$(shell date +%Y%m%d%H%M%S)

export AMI_OS_INFO=$(AMI_OS)-$(AMI_OS_RELEASE)
export AMI_DESCRIPTION=$(AMI_OS_INFO): $(AMI_DESC_TXT)
export AMI_NAME=$(AMI_PREFIX)-$(AMI_OS_INFO)-$(BUILD_TIME)-$(AMI_NAME_GIT_INFO)
export AMI_SOURCE_ID?=$(shell                                            \
	aws --cli-read-timeout 10 ec2 describe-images --region $(AWS_REGION) \
	--filters 'Name=manifest-location,Values=$(AMI_SOURCE_FILTER)'        \
	--query 'Images[*].{ID:ImageId}'                                     \
	--output text                                                        \
)

export AWS_TAG_AMI_SOURCES=$(AMI_PREVIOUS_SOURCES)$(AMI_PREFIX)[$(AMI_SOURCE_ID)]
export AWS_TAG_BUILD_GIT_INFO=repo<$(BUILD_GIT_REPO)>branch<$(BUILD_GIT_BRANCH)>
export AWS_TAG_BUILD_GIT_REF=tag<$(BUILD_GIT_TAG)>sha<$(BUILD_GIT_SHA)>
export AWS_TAG_OS_INFO=os<$(AMI_OS)>os_release<$(AMI_OS_RELEASE)>

export PACKER?=$(shell which packer)

# ... validate MANDATORY_VARS are defined
check_defined = $(foreach 1,$1,$(__failures))
__failures = $(if $(value $1),, $(error You must pass env_var $1 to Makefile))

.PHONY: help
help: ## Run to show available make targets and descriptions
	@echo $(failures)
	@echo [INFO] Packer - Available make targets and descriptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)            \
	    | sort                                                     \
	    | awk 'BEGIN {FS = ":.*?## "};{printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}';

.PHONY: show_env
show_env: ## show me my environment
	@echo [INFO] EXPORTED ENVIRONMENT - AVAILABLE TO ALL TARGETS
	@env | sort | uniq

.PHONY: check_vars
check_vars: ## checks mandatory vars are in make's env or fails
	$(call check_defined, $(MANDATORY_VARS))
	@echo "All mandatory vars are defined:"
	@echo "$(MANDATORY_VARS)"

.PHONY: sshkeyfile
sshkeyfile: ## Symlink local sshkey to directory to use in Packer
	@if [ -f ./$(SSH_PRIVATE_KEY_FILE) ];                                            \
	    then echo "[INFO] Found sshkey: ./$(SSH_PRIVATE_KEY_FILE)";                  \
	elif [ -f ~/.ssh/$(SSH_PRIVATE_KEY_FILE) ];                                      \
	then                                                                             \
	    echo "[INFO] Found sshkey creating symlink: ~/.ssh/$(SSH_PRIVATE_KEY_FILE)"; \
	    ln -sf ~/.ssh/$(SSH_PRIVATE_KEY_FILE) ./$(SSH_PRIVATE_KEY_FILE);             \
	else                                                                             \
	    echo -e "\033[0;31m[ERROR] Create a copy of sshkey in current directory"     \
	    echo -e "(or symlink): e.g ./$(SSH_PRIVATE_KEY_FILE)\e[0m\n";                \
	    exit 1;                                                                      \
	fi;

.PHONY: validate
validate: check_vars sshkeyfile ## Run packer validate using defined variables
	@PACKER_LOG=$(PACKER_LOG) packer validate "$(PACKER_JSON)"

# TODO: on successful build, share the AMI with the AWS Prod account?
.PHONY: build
build: validate ## run packer validate then build
	@PACKER_LOG=$(PACKER_LOG) packer build $(PACKER_DEBUG) "$(PACKER_JSON)"

