TERRAFORM ASSESSMENT PROJECT
This is an Infrastructure-as-Code project that automates the deployment of a complete, enterprise-grade Kubernetes platform on Azure. In one command, we provision an AKS cluster, container registry, networking, and security policies that would normally take days to set up manually.
What are the CIDR range 
What are resource you have created in this project 
How this value has been updated and triggered to use by main.tf 
 how you have accommodated state file (terraform backend and used blob storage to save the file) 
 What is drift detection 
 How you did this, 
POC doc, used multiple AI to understand first then used VS code to update the same after created repo in github 
installed terraform locally update env variables,  
I used reusable modules for reusability and also separated each module. Each module is independently manageable and reusable across environments like dev, prod, test.
Explain Modules:
Network Module
•	VNet + Subnet 
Explain:
AKS requires a subnet to deploy nodes, so I created a dedicated subnet for cluster isolation.
________________________________________
ACR Module
Private container registry 
Explain:
ACR stores container images securely. I disabled admin access and used role-based access for AKS integration.
________________________________________
AKS Module
Cluster creation, Node pool, ACR integration 
I attached ACR to AKS using role assignment so the cluster can pull images securely without credentials.
Remote Backend
I configured remote backend using Azure Storage Account to store Terraform state. This enables:
State locking

terraform init/ terraform init –upgrade
- initializes the Terraform working directory, Downloads required providers (Azure provider)
Without init, Terraform cannot interact with any cloud provider.
It ensures we are using updated provider plugins without manually deleting files.
terraform validate
This command checks whether the configuration is structurally correct. It will check syntax errors, missing variables, this is just for local validation, it does not contact azure or any
It helps catch errors early before planning or deployment
terraform plan
This command shows what Terraform is going to do before actually doing it.
Resources to be created, modified, destroyed
terraform apply / terraform apply -auto-approve
This command actually provisions or updates the infrastructure.
Apply is where the infrastructure is actually created based on the declared configuration
It will execute the plan
Creates resources in Azure or in any and also it will updates state file
terraform destroy
This command is used to delete all the infrastructure managed by Terraform.
=====================================================================================
Q1: Why did you use Terraform?
 “Terraform provides declarative infrastructure, version control, and reproducibility. It ensures the same environment can be recreated anytime without manual errors.”
Q2: What is Terraform State?
“Terraform state is a file that maps real infrastructure to configuration. It helps Terraform track what is already created and what needs to change.”
Q3: Why Remote State? “Remote state allows multiple team members to collaborate safely and prevents conflicts using state locking.”
Q4: What is a Module?
 “A module is a reusable Terraform component that encapsulates resources. It helps maintain clean, scalable, and DRY code.”
Q5: How did you handle dependencies?
“Terraform automatically handles dependencies using resource references. For example, AKS depends on subnet ID from network module.”
Q6: How does AKS pull images from ACR?  “Using role assignment (AcrPull role), I allowed AKS to securely access ACR without exposing credentials.”
Q7: What happens if state file is deleted?
 “Terraform loses track of resources, which may lead to duplication or drift. That’s why remote backup and versioning are important.”
 Q8: Difference between implicit and explicit dependency?
Implicit → via reference (subnet_id = module.network.subnet_id) | Explicit → depends_on
Q9: How can you make this production ready?
Adding private AKS cluster
Using managed identities
Enabling monitoring (Azure Monitor)
Implementing CI/CD pipeline
Adding autoscaling”
Q10: What challenges did you face?
 “Handling module dependencies and remote backend configuration was challenging initially, especially ensuring correct resource references.”


