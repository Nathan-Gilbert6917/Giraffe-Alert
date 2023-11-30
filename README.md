## How TO: Run Terraform Script

# Testing Information
- Put images of giraffe into the bucket defined under the image_api_bucket variable in the main.tf file. The default is giraffe_upload.
- Load time: About 5 minutes TODO again after more changes happen
- Destroy Time: About 5 minutes TODO again after more changes happen

# Update main.tf File
- At the top of the file inside of main.tf 
- Update region to your desired region
- Update image_api_bucket to your desired bucket
- Update github_access_token to your desired token
- Update the database username and password if you want to. Otherwise it will be set by default.
- Save this file

# Getting Started
- Create a S3 bucket named "giraffe-terra-test" or
change to the one you set in the terraform file.
- Instantiate and connect to an EC2 instance, if it already has Terraform installed continue to next step, if not:
- `sudo yum install -y yum-utils`
- `sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`
- `sudo yum -y install terraform`
- Validate Terraform is installed by using `terraform -version`
- Configure AWS CLI by running `aws configure`

# Moving Files
Once Terraform is successfully installed you need to transfer the Terraform files to our EC2 instance
- Create a S3 Bucket
- Once the bucket is created upload the folder containing the Terraform files
- Run `aws s3 cp s3://giraffe-terra-test . --recursive`
- OR `aws s3 cp s3://[your-bucket-name] . --recursive`
# Running Terraform
With our files on our EC2 and Terraform installed, we are now ready to run our setup
- Run `terraform init` to startup Terraform
- Run `terraform plan` to make sure setup is accurate and everything is being created as it should
- Run `terraform apply` to run our plan!

# Checking everything is working
After `terraform apply` completes, check 
- Open up AWS and go to Amplify.
- Build the frontend from there.

# Teardown
After testing, run `terraform destory` to teardown all the created infrastructure
