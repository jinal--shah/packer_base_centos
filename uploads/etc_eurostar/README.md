# etc\_eurostar

## purpose

Dump files in this dir that you want to live under
/etc/eurostar/ on one of our instances.

These files should contain key=val pairs that 
describe aspects of the instance or the eurostar environment

*These must be values that remain the same for the lifetime of the instance.*

If a value can only be realised after the instance is up
(and can't be baked in to the AMI e.g. env) then don't
put it in a file here - use a cloud-init script to generate
the file at instance-up time.

e.g.
    # /etc/eurostar/eurostar_domain_info
    EUROSTAR_AWS_DOMAIN_PROD=aws.eurostar.com
    EUROSTAR_AWS_DOMAIN_NONPROD=aws.trainz.io

## what can I do with these files?

Well, they can help with understanding the estate from the point
of view of the instance.

More usefully, they can be sourced in a bash script (e.g. an app's
startup process) making these key=vals available as env vars.

That allows env-specific logic to be handled at run-time, rather than
create separate AMIs per env.
