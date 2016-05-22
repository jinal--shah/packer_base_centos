[1]: https://github.com/henrysher/cob/blob/master/cob.py "github cob s3 yum plugin"
# cob.py - yum plugin to treat S3 buckets as repos

 See original code here [in github here][1].
 
 This version of cob.py has been modified to honour env vars for
 AWS access credentials:

    $AWS_ACCESS_KEY_ID
    $AWS_SECRET_ACCESS_KEY

# Usage

    # ... make sure yum-utils is installed
    # To enable cob S3 repo eurostar_prod:
    yum-config-manager --enable eurostar_prod

    # To disable cob S3 repo eurostar_prod:
    yum-config-manager --disable eurostar_prod

# ... Included

	cob/
	├── README.cob.md
	├── etc
	│   └── yum
	│       └── pluginconf.d
	│           └── cob.conf # retries for IAM creds etc ...
	└── usr
		└── lib
			└── yum-plugins
				└── cob.py

