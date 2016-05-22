# packer_base_centos_aws

Assets used to build a base AMI for Eurostar projects with daringly permissive
adjustments to selinux and iptables, and a progressive attitude to rpm updates.

It is also responsible for the creation of the standard ec2-user.

*ADD STUFF TO THIS LAYER THAT SHOULD REALLY EXIST ON ANY EUROSTAR PROJECT*

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

* After it is smoke tested, merge to master, build and test comprehensively.

* *On successful testing, the AMI's channel tag should be set to  _stable_.*

  _Obviously, this should be automated ..._

  It is this stable, tested ami that later ami layers will look for to use
  as a base.

  *See examples of changing tags and discovering appropriate AMIs below.*


## OUTPUT

The resulting AMI is named:

        eurostar_aws-<os info>-<build time>-<src's git sha>-<src's git branch>

        e.g.

        eurostar_aws-centos-6.5-20160522105037-0ad9aa7a-master

See generated value $AMI_NAME in Makefile for more details.

## DISCOVERY

        e.g. find ami_id for latest stable centos from a EurostarDigital master branch:

        aws --cli-read-timeout 10 ec2 describe-images --region $AWS_REGION  \
            --filter 'Name=manifest-location,Values=*/eurostar_aws-centos*' \
            --filter 'Name=tag:build_git_org,Values=EurostarDigital'        \
            --filter 'Name=tag:build_git_branch,Values=master'              \
            --filter 'Name=tag:channel,Values=stable'                       \
            --query 'Images[*].[ImageId,CreationDate]'                      \
            --output text                                                   \
            | sort -k2 | tail -1 | awk {'print $1'}


## MARKING AS STABLE

        e.g. assumes you know the ami id

        aws ec2 create-tags --region=$AWS_REGION \
        --resources $AMI_ID                      \
        --tags 'Key=channel,Value=stable'


