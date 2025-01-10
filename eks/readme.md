### AWS Crdentioal Location

The credentials and config file are updated when you run the command aws configure.
The credentials file is located at ``~/.aws/credentials`` on Linux or macOS, 
or at ``C:\Users\USERNAME\.aws\credentials`` on Windows.


### Access EKS cluster with IAM user manager
1. Update credential for profile manager
```cmd
aws configure --profile manager
```
2. Assume IAM role
```cmd
aws sts assume-role \
--role-arn arn:aws:iam::{AWS Account}:role/{Role Name} \
--role-session-name manager-session \
--profile manager
```

### Template for getting eks auth token in terraform
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth

### Deloy on Kubernetes
1. Apply configuration of creating resource
```cmd
kubectl apply -f example
```
2. Get pods with specific namespace
```cmd
kubectl get pods -n example
```

### Cluster Autoscaler VS HPA
- cluster Autosaclar - cluster level
- HPA - pod level

### AWS EKS Addon
*Check latest eks addon version*
```cmd
aws eks describe-addon-versions \
--region us-east-1 \
--addon-name eks-pod-identity-agent
```

*Avaliable Addon List*
https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html

### More About HPA and Cluster Autoscaler
* If no node affinity role
- Pods for different namespace may work on the pods in same node

* Cluster Autoscaler
- Adds or removes nodes based on the pending pods

* Pending Pod (some reason)
1. Resource Constraints
- If no node can provide the required resource of the pod, the pods will become pending

### Kubernetes Service Type
* ClusterIP vs NodePort vs LoadBalancer

*ClusterIP*
- Service accessible only WITHIN same cluster
- Pods and nodes communicate with the service using the ClusterIP

*NodePort*
- Expose the Service on a port

*LoadBalancer*
- accssible externally through cloud providers LoadBalancer (e.g. AWS, Azuer, GCP)

### AWS Load Balancer Controller
- IAM Policy
https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json

- Ingress Approach vs Kubernetes Service LoadBalancer type Approach
Ingress
- LBC creates ALB when create a Kubernetes Ingress

Kubernetes Service LoadBalancer type
- LBC creates NLB when create a Kubernetes service of type LoadBalancer
- costly as it will create a NLB for each service

https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

### Check certificate 
```cmd
kubectl get certificate -n [namespace]
```

### Show Detail of certificate
```cmd
kubectl describe certificate -n [namespace]
```

### Cert Manager Let'sEncrypt Challenge
- Remember to create CName Record of hostname to Load Balancer

### Use Pod Identity to Associate a IAM role to service account
1. Create IAM Policy Document
2. Create IAM Role and assume above policy document
3. Create IAM Policy for the role
4. Attach above IAM Policy to the role
5. Associate IAM Role to Service Account with Pod Identity
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association 

### Statefulset
#### serviceName field in Statefulset
- Ensure stable network identities for Pods
- As it doesn't have ClusterIP, no load balancing providing
- Use Headless Service to manage Pods DNS records
- Provide  each Pod in StatefulSet gets a unique DNS name when serviceName is set
```
<pod-name>.<service-name>.<namespace>.svc.cluster.var
```
e.g. service-name: my-service, namespace: example
```
pod-0.my-service.example.svc.cluster.var
pod-1.my-service.example.svc.cluster.var
```