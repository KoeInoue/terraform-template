# terraform-template
### Install Terraform
install Terraform on your device before start.  
[Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

check if its installed correctly.  
`terraform version`

### Create Variable File
create variable file for credential value.  
`touch terraform.tfvars`

define these variables below.
```
# IAM user access key
aws_access_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
# IAM user secret key
aws_secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
# RSA key name
key_name = "xxxxxx"
# RSA public key path
public_key_path = "~/.ssh/xxxxxx.pub"
```

### init
If you write a new setting in Terraform, you need to initialize it.
Since the provider is not built in the plain Terraform, the AWS provider will be downloaded this time.

Let's initialize.  
`terraform init`

### apply
apply the code state on AWS.  
`terraform apply`

Now you can see resources on AWS console!