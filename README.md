## Terraform Templates to Deploy GlobalProtect onto AWS

### PreRequisites:
- To generate new SSH Keys, on a Mac, run the command ssh-keygen -f globalprotect_demo_key -t rsa -N '' in the keys/ directory. On Windows, you can use PuttyGen to generate new SSH keys.
- Please change the S3 bucket name to a globally unique name. You do not need to create the S3 buckets before running the deployment, new S3 buckets will be created.
- Please change the default username/password of admin/Pal0Alt0@123 immediately!
- I did not include my Route53 Zone ID in the config, if you'd like to leverage my template for demo's, feel free to contact me and I'll share.
- Please see section 2 below pertaining to Credentials and Authentication.

### Code Organization:
    aws_two-tier/

    - aws_two_tier.tf: Contains the definition of the various artifacts that will be deployed on AWS.
    
    - aws_vars.tf: Define the various variables that will be required as inputs to the Terraform template.
    
    - terraform.tfvars: Defines default values for all the variables.

Note: The aws_vars.tf has default values provided for certain variables. These can obviously be overridden by specifying those variables and values in the terraform.tfvars file.

### Credentials and Authentication:
Create a file called aws_creds.tf to provide the AWS ACCESS_KEY and SECRET_KEY.

The structure of the aws_creds.tf file should be as follows:

    provider "aws" {
      access_key = "<access_key>"
      secret_key = "<secret_key>"
      region     = "${var.aws_region}"
    }
You can add the Unique S3 bucket name and Route53 Zone ID to the terraform.tfvars file as below:

    MasterS3Bucket = "<unique-S3-bucket-name>"
    aws_route53_zone = "<zone-id>"

If you don't add the S3 bucket name or zone-id, you will be prompted to enter them in during deployment.

### Usage:
`terraform init` 

`terraform apply`

### Notes:

- The intention of this configuration is to show how GlobalProtect can be used for remote users/developers to work on applications/servers in a private subnet within a VPC.
- The bootstrap.xml file has GlobalProtect pre-configured to use the Untrust (eth1/1) interface as both the Portal and Gateway with an FQDN of gpawsdemo.com and with a Local and Okta SAML authentication profile for the Portal and Gateway with a single user. The Okta SAML authentication profile has higher precendence than the Local authentication profile, so after inital setup, the Okta SAML profile will be used for GlobalProtect Portal and Gateway authentication. Please contact me for the test user for Okta SAML authentication. The Local username is 'test' and password is 'paloaltonetworks'.  *** The self-signed certificate for gpawsdemo.com should be saved on Windows Machines, but will need to manually saved and trusted on Mac with KeyChain access ***
- After the NGFW has successfully turned on, if you don't already have a GlobalProtect client downloaded, point your browser to https://www.gpawsdemo.com and authenticate with the Okta SAML username/password, contact me if you need the account credentials. If you switched the Authentication to Local, use the username 'test' and password 'paloaltonetworks'. If you already have a GlobalProtect client, point the client to use the Portal gpawsdemo.com.
- To SSH to the web or db host, you will only be able to after connecting via GlobalProtect.
- You can use the same private key generated, globalprotect_demo_key, to ssh into the Ubuntu Web (10.0.1.101) and DB (10.0.2.101) servers. For example ssh -i keys/two_tier_vpc_key ubuntu@10.0.1.101
- The web and db subnets have their default routes point the firewall's web and db interface. No need to change default route of the instances from x.x.x.1.
- Again, change the default password (admin/Pal0Alt0@123) of the firewall!



### Support:
This template is a fork of the Palo Alto Networks terraform template and is released under an as-is, best effort, support policy. These scripts should be seen as community supported and will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself. Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.
