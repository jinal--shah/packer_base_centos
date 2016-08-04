# vim: ts=4 st=4 sr noet smartindent:
#
# ### MANDATORY_VARS
include packer_includes/make/mandatory_vars/common.mak

# ### CONSTANTS (not user-defineable)
# SSH_PRIVATE_KEY_FILE ... for build this is the AWS dev account's 'eurostar' key
#
AMI_PREVIOUS_SOURCES:=
GIT_SHA_LEN:=8
PACKER_JSON:=packer.json
export PACKER_INCLUDES_GIT_TAG=3.0.4
export AMI_PREFIX:=eurostar_aws
export AMI_OS:=centos
export AMI_OS_RELEASE:=6.5
export AMI_SOURCE_PREFIX:=base
export AMI_SOURCE_FILTER:=aws-marketplace/CentOS 6 x86_64*EBS*HVM*
export SHELL:=/bin/bash
export SSH_KEYPAIR_NAME:=eurostar
export SSH_PRIVATE_KEY_FILE:=eurostar.pem
export SSH_USERNAME:=root

# ### VARS (user-defineable)
# AMI_SOURCE_ID: ami that this new one builds on, determined by make
# PACKER_LOG: set to 1 for verbose - but the security-conscious be warned:
#             this will log all env var values including aws access creds ...
# PACKER_DEBUG: set to -debug for breakpoint mode. BUT, BUT, BUT ...
#               THERE IS A BUG IN PACKER 0.10.0 - DEBUG WILL HANG
#
export AWS_ACCESS_KEY_ID?=
export AWS_INSTANCE_TYPE?=t2.large
export AWS_REGION?=eu-west-1
export AWS_SECRET_ACCESS_KEY?=
export PACKER_DEBUG?=
export PACKER_LOG?=
export PACKER_DIR?=./

# ### GENERATED VARS: determined by make based on other values.
# AMI_NAME : must be unique in AWS account, so we can locate it unambiguously.
# BUILD_GIT_*: used to AWS-tag the built AMI, and generate its unique name
#              so we can trace its providence later.
#
# ... to rebuild using same version of tools, we can't trust the git tag
# but the branch, sha and repo, because git tags are mutable and movable.
ifeq ($(BUILD_URL),)
	AUDIT_MSG=$(shell git config user.name)@$(HOSTNAME)
else
	AUDIT_MSG=$(BUILD_URL)
endif
export AUDIT_MSG

export BUILD_TIME:=$(shell date +%Y%m%d%H%M%S)

export BUILD_GIT_TAG:=$(BUILD_TIME)
export BUILD_GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)

export BUILD_GIT_SHA:=$(shell git rev-parse --short=$(GIT_SHA_LEN) --verify HEAD)
export BUILD_GIT_REPO:=$(shell \
	git remote show -n origin  \
	| grep '^ *Push *'         \
	| awk {'print $$NF'}       \
)
export BUILD_GIT_ORG:=$(shell            \
	echo $(BUILD_GIT_REPO)               \
	| sed -e 's!.*[:/]\([^/]\+\)/.*!\1!' \
)

AMI_NAME_GIT_INFO:=$(BUILD_GIT_BRANCH)-$(BUILD_GIT_SHA)
DESC_TXT:=yum updates;ec2-user;permissive settings;awscli;cob;basic ops pkgs;ntp
export AMI_OS_INFO:=$(AMI_OS)-$(AMI_OS_RELEASE)
export AMI_DESCRIPTION:=$(AMI_OS_INFO): $(DESC_TXT)
export AMI_NAME:=$(AMI_PREFIX)-$(AMI_OS_INFO)-$(BUILD_GIT_ORG)-$(BUILD_TIME)
export AMI_SOURCE_ID?=$(shell                                            \
	aws --cli-read-timeout 10 ec2 describe-images --region $(AWS_REGION) \
	--filters 'Name=manifest-location,Values=$(AMI_SOURCE_FILTER)'       \
	--query 'Images[*].{ID:ImageId}'                                     \
	--output text                                                        \
)

export AWS_TAG_AMI_SOURCES:=$(AMI_PREVIOUS_SOURCES)<$(AMI_SOURCE_PREFIX):$(AMI_SOURCE_ID)>
export AWS_TAG_BUILD_GIT_INFO:=repo<$(BUILD_GIT_REPO)>branch<$(BUILD_GIT_BRANCH)>
export AWS_TAG_BUILD_GIT_REF:=tag<$(BUILD_GIT_TAG)>sha<$(BUILD_GIT_SHA)>
export AWS_TAG_OS_INFO:=os<$(AMI_OS)>os_release<$(AMI_OS_RELEASE)>

export PACKER?=$(shell which packer)

# ... run 'make' or 'make help' to see where each recipe is defined
include packer_includes/make/recipes/common.mak

.PHONY: prereqs
prereqs: no_detached_head sshkeyfile ## set up build env

.PHONY: validate
validate: check_vars check_includes check_for_changes valid_packer ## check build env is sane

.PHONY: build
build: prereqs validate tag_project run_packer push_tags ## run prereqs, validate, build. On success, push tags

