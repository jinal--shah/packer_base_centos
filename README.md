# packer\_base\_centos\_aws

Assets used to build a base AMI for Eurostar projects with daringly permissive
adjustments to selinux and iptables, and a progressive attitude to rpm updates.

It is also responsible for the creation of the standard ec2-user.

*ADD TO THIS LAYER THINGS THAT ARE AXIOMATIC FOR ANY EUROSTAR RHEL-BASED LINUX*

## BUILD

        # export all user-defined env vars, and then:
        make build

* makefile inherits values from env vars. These are transformed and / or
  passed on to packer which maps them to packer _user_ vars.

* Packer runs a few scripts under the yawn-inducingly-named scripts dir to
  provide the basic ami env.

## CHANGES WORKFLOW

* make a git branch from master.

* make your changes and push to your branch

* build from your branch

* The AMI will have a channel tag, set to _dev_.

* After it is tested, merge to master.

* **On successful testing, the AMI's channel tag should be set to  _stable_.**

  _Obviously, this should be automated ..._

  It is this stable, tested ami that later ami layers will look for to use
  as a base.

  **See examples of changing tags and discovering appropriate AMIs below.**


## OUTPUT

The resulting AMI is named:

        eurostar_aws-<os info>-<build git org>-<build time>

        e.g.

        eurostar_aws-centos-6.5-EurostarDigital-20160522105037

See generated value $AMI\_NAME in Makefile for more details.

## DISCOVERY

        e.g. find ami_id for latest stable from a EurostarDigital master branch:
        GIT_INFO="repo<*EurostarDigital/*>branch<master>"
        aws --cli-read-timeout 10 ec2 describe-images --region $AWS_REGION \
            --filters 'Name=manifest-location,Values=*/eurostar_aws*'      \
                      'Name=tag:build_git_info,Values=EurostarDigital'     \
                      'Name=tag:channel,Values=stable'                     \
            --query 'Images[*].[ImageId,CreationDate]'                     \
            --output text                                                  \
            | sort -k2 | tail -1 | awk {'print $1'}


## MARKING AS STABLE

        e.g. assumes you know the ami id

        aws ec2 create-tags --region=$AWS_REGION \
        --resources $AMI_ID                      \
        --tags 'Key=channel,Value=stable'


