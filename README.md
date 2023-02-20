# Deploy Wordpress on GCP Instances via Kubespay

This is a list of instructions to deploy:

1. **git clone https://github.com/AndrukhivAndriy/GLfinaltask.git**

2.       export TF_VAR_DBusername=wordpress-user # Change "wordpress-user" to other username or don't change it 
         export TF_VAR_DBpassword=wordpress  # Change "wordpressr" to other password or don't change it 
   
3.     terraform init
       terraform plan
       terraform apply
   
4.      kubectl create secret generic dev-db-secret --from-literal=username=wordpress-user --from-literal=password=wordpress  --from-literal=address=DB_IP_ADDRESS --from-literal=database=wordpress-db  

5. **ansible-playbook word.yaml**
   
   
   
