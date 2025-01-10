### Basic Infrastructure
1. VPC
```vpc.tf```
2. Internet Gateway
```igw.tf```
3. Subenets
```subnets.tf```
4. NAT Gateway + Elastic IP
```nat-gateway.tf```
5. Route Tables
```routes.tf```

### Amazon Elastic Kubernetes Service (EKS)
1. EKS Cluster
```eks.tf```
2. EKS Nodes
```nodes.tf```

### Advanced:
##### providers
- helm
- kubernetes

##### RBAC Authorization
```add-manager-role.tf```

1. Horizontal Pod Autoscaler
```metrics-server.tf```

2. Cluster Autoscaler
```cluster-autoscaler.tf```
```eks-pod-indentity-agent.tf```

3. Load Balancing
a. AWS Load Balancer Controller
```lbc.tf```
b. Nginx Ingress Controller
```nginx-ingress.tf```
```cert-manager.tf```

4. Storage
a. Elastic Block Store (EBS)
```ebs-csi-driver.tf```
b. Elastic File Store (EFS)
```efs.tf```
```openid-connect-provider.tf```
