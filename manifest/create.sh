#!/bin/bash

# Define the path to the SSH key
SSH_KEY="manifest/eks-node-key.pem"

# Step 1: Update kubeconfig for EKS cluster
echo "Updating kubeconfig for EKS cluster..."
aws eks --region eu-west-1 update-kubeconfig --name my-eks-cluster

# Step 2: Get services in the cluster
echo "Getting services in the cluster..."
kubectl get svc

# Step 3: Create namespace
echo "Creating Jenkins and monitoring namespace..."
kubectl create namespace jenkins
kubectl create namespace monitoring
kubectl create namespace inventory
kubectl create namespace order

# Step 4: Get the list of nodes and capture the first node name
echo "Getting nodes information..."
kubectl get nodes -o wide

# Step 5: Fetch the first node's internal name (assumes node name is the first in the list)
first_node=$(kubectl get nodes -o wide | awk 'NR==2 {print $1}')
second_node=$(kubectl get nodes -o wide | awk 'NR==3 {print $1}')
echo "First node: $first_node"
echo "Second node: $second_node"

# Step 6: Label the first node for devops
echo "Labeling the first node for devops..."
kubectl label node $first_node devops=true

echo "Labeling the second node for development..."
kubectl label node $second_node development=true


# Step 7: Apply persistent volume and claim manifest under the 'jenkins' namespace
echo "Applying Persistent Volume and Persistent Volume Claim..."
kubectl apply -f manifest/jenkins.yaml -n jenkins
kubectl apply -f manifest/monitoring.yaml -n monitoring

# Step 8: SSH into both nodes and set permissions for Jenkins on the /mnt/data directory
echo "Fetching external IPs of the nodes..."
node_ips=($(kubectl get nodes -o wide | awk 'NR>1 {print $7}'))

# Step 9: SSH into each node and change the permissions for /mnt/data
for ip in "${node_ips[@]}"; do
  echo "Connecting to node $ip..."
  ssh -i "$SSH_KEY" ec2-user@$ip << EOF
    echo "Changing permissions on /mnt/data..."
    sudo chown -R 1000:1000 /mnt/data
    sudo chmod -R 775 /mnt/data
    exit
EOF
done

echo "Permissions have been updated on all nodes."

# Step 10: Apply  deployment manifest 
echo "Applying deployment manifest..."
kubectl apply -f manifest/jenkins-deployment.yaml -n jenkins
kubectl apply -f manifest/prometheus-deployment.yaml -n monitoring
kubectl apply -f manifest/grafana-deployment.yaml -n monitoring
kubectl apply -f manifest/inventoryapp.yaml 
kubectl apply -f manifest/orderapp.yaml 


# Step 11: Get Jenkins pod status
echo "Getting Jenkins pod status..."
kubectl get pods -n jenkins

# Step 12: Get Jenkins service status
echo "Getting Jenkins service status..."
kubectl get svc jenkins-service -n jenkins

# Step 13: Get prometheus pod status
echo "Getting prometheus pod status..."
kubectl get pods -n monitoring

# Step 14: Get prometheus service status
echo "Getting prometheus service status..."
kubectl get svc prometheus -n monitoring

# Step 15: Get grafana pod status
echo "Getting grafana pod status..."
kubectl get pods -n monitoring

# Step 16: Get grafana service status
echo "Getting grafana service status..."
kubectl get svc grafana-service -n monitoring

# Step 15: Get inventory pod status
echo "Getting inventory pod status..."
kubectl get pods -n inventory

# Step 16: Get inventory service status
echo "Getting inventory service status..."
kubectl get svc inventory-service -n inventory

# Step 15: Get iorder pod status
echo "Getting order pod status..."
kubectl get pods -n order

# Step 16: Get order service status
echo "Getting order service status..."
kubectl get svc order-service  -n order