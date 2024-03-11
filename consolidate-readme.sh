#! /usr/bin/env bash

cat - app/README.md eb/README.md ec2/README.md /dev/fd/3 > README.md <<- 'END_HEADER' 3<<- 'END_FOOTER'
	# orca-deploy

	Packager project for NCLS Development's [Orca](https://www.orca-solution.com/) solution.

	## Usage

	1. Build and publish a [Docker](https://www.docker.com/) image of the Web server using the instructions found under [`app/`](./app).
	2. Deploy the environment either using either:

	   - [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) (see [`eb/`](./eb)), or
	   - directly onto a simple [EC2 instance](https://aws.amazon.com/ec2/) (see [`ec2/`](./ec2)).

	   The main difference between these two approaches is the SSL setup.

	## Release note

	Don't forget to compile and publish `setup.tag.gz` with each release:

	```shell
	tar --directory ec2/setup -czvf setup.tar.gz .
	```
END_HEADER
	## Environment variables

	| Name                  | Description                                                               |
	| --------------------- | ------------------------------------------------------------------------- |
	| `AWS_ACCESS_KEY_ID`\* | Access Key ID of user with full access to `arn:aws:s3:::orca-resources`   |
	| `AWS_SECRET_KEY`\*    | Secret Key of user with full access to `arn:aws:s3:::orca-resources`      |
	| `ORCA_DB_HOST`\*      | [RDS](https://aws.amazon.com/rds/) hostname                               |
	| `ORCA_DB_NAME`\*      | [RDS](https://aws.amazon.com/rds/) database name                          |
	| `ORCA_DB_USER`\*      | Database user name                                                        |
	| `ORCA_DB_PASS`\*      | Database user password                                                    |
	| `ORCA_DEMO_ENABLED`   | `true` iff the demo mode should be enabled                                |
	| `ORCA_INIT_SECRET`    | Used to trigger a (re)initialisation of the database or a demo data reset |
	| `CORS_ORIGIN`         | Used to set the `Access-Control-Allow-Origin` header                      |

	> **\*** - Required
END_FOOTER
