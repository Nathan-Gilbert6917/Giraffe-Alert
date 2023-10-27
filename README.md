## How TO: Run Terraform Script

# Update File
- At the top of the file inside of main.tf 
- Update region to your desired region
- Update image_api_bucket to your desired bucket
- Save this file

# Getting Started
Instantiate and connect to an EC2 instance, if it already has Terraform installed continue to next step, if not:
- `sudo yum install -y yum-utils`
- `sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`
- `sudo yum -y install terraform`
- Validate Terraform is installed by using `terraform -version`
- Configure AWS CLI by running `aws configure`

# Moving Files
Once Terraform is successfully installed you need to transfer the Terraform files to our EC2 instance
- Create a S3 Bucket
- Once the bucket is created upload the folder containing the Terraform files
- Run `aws s3 cp s3://[your bucket name] . --recursive`

# Running Terraform
With our files on our EC2 and Terraform installed, we are now ready to run our setup
- Run `terraform init` to startup Terraform
- Run `terraform plan` to make sure setup is accurate and everything is being created as it should
- Run `terraform apply` to run our plan!
After `terraform apply` completes, check 
- Lambda function is created and running
- CloudWatch rule is created and enabled
- s3 bucket for images being uploaded every minute

# Teardown
After testing, run `terraform destory` to teardown all the created infrastructure
