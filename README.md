# packer_base_centos_aws

Assets used to build a base AMI for Eurostar projects with daringly permissive
adjustments to selinux and iptables, and a progressive attitude to rpm updates.

It is also responsible for the creation of the standard ec2-user.

*ADD STUFF TO THIS LAYER THAT SHOULD REALLY EXIST ON ANY EUROSTAR PROJECT*

## BUILD

        # export all user-defined env vars, and then:
        make clean build

* makefile inherits values from env vars. These are transformed and / or
  passed on to packer which maps them to packer _user_ vars.

* Packer runs a few scripts under the yawn-inducingly-named scripts dir to
  provide the basic ami env.

## CHANGES WORKFLOW

* make a git branch from master.

* make your changes and push to your branch

* build from your branch

* The AMI will be suffixed with the name of the git branch

* After it is sufficiently tested, it should be merged in to master and
  a the ami name's suffix changed from the branch name to _master_.

  _Obviously, this should be automated ..._

  It is this stable, tested ami that later ami layers will look for to use
  as a base.


## OUTPUT

The resulting AMI is named:

        eurostar-base_centos-<os_version>-<build_time>-<branch_tag>

        e.g.

        eurostar-base_centos-6.5-20160601101734-master

