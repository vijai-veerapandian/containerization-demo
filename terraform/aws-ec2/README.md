## Terraform AWS EC2 and Terraform state file in S3 Setup

I have created this Terraform to provision AWS infrastructure, including an EC2 instance and an S3 bucket for storing the Terraform state file.

---

## **Features**
1. **S3 Backend for Terraform State**:
   - The Terraform state file is stored in an S3 bucket (`mytf-state-app-bucket`) with versioning enabled and public access blocked.

2. **Auto-Generated SSH Key**:
   - A private key (`ec2awskey.pem`) is generated locally for SSH access to the EC2 instance.

---

## **Prerequisites**
1. **Terraform**:
   - Install Terraform: [Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. **AWS CLI**:
   - Install AWS CLI: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
   - Configure AWS CLI with your credentials:
     ```bash
     aws configure
     ```

3. **AWS IAM Permissions**:
   - Ensure the IAM user or role has permissions to manage EC2, S3, and VPC resources.

---

## **Setup Instructions**

### **1. Clone the Repository**
```bash
git clone <repository-url>
cd tfaws-ec2-s3
```

2. Initialize Terraform
Initialize Terraform and configure the backend:
```bash
terraform init
```
3. Create the S3 Bucket
If the S3 bucket (mytf-state-app-bucket) does not exist, create using the bootstrap.tf file:
```bash
cd bootstrap/
terraform init
terraform apply
```
4. Apply the Terraform Configuration
Check the main.tf file and then deploy the infrastructure:
```bash
terraform plan 
terraform validate
terraform apply
```
Accessing the EC2 Instance
1. Get the Public IP Address:

Run the following command to retrieve the public IP:

```bash
terraform output instance_public_ip
```
2.SSH into the Instance:
    Use the private key (ec2awskey.pem)to SSH into the instance:
```bash
ssh -i ec2awskey.pem ubuntu@<instance-public-ip>
```
Replace <instance-public-ip> with the actual public IP address.

# Key Components

Cleanup
To destroy the infrastructure, run:
```bash
terraform destroy
```
Troubleshooting 
1. S3 Bucket already exists:
    If the S3 bucket already exists, remove the aws_s3_bucket resource from the configuration or import it into Terraform:
```bash
terraform import aws_s3_bucket.terraform_state mytf-state-app-bucket
```
2. SSH Permission denied:
    Ensure the private key file(ec2awskey.pem) has the correct permissions:
```bash
chmod 600 ec2awskey.pem
```
3. If the any of the resource state file is corrupted or not responding. Manually remote the state.
```bash
terraform state list
terraform state rm aws_instance.demo_app <id-instance-id>
terraform state list
terraform destroy
```
