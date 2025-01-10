example: Horizontal Pod Autoscaling(HPA)

example-2: Kubernetes Service LoadBalancer type(AWS NLB)
Client --> AWS NLB --> Pods

example-3: Ingress(AWS Load Balancer Controller provision ALB)
Client --> AWS ALB (Handle Routing Logic) --> Pods

example-4: Ingress(AWS Load Balancer Controller provision ALB) + AWS ACM
Client --> AWS ALB (Handle Routing Logic and TLS Termination)--> Pods

example-5: AWS NLB + Nginx ingress controller + Cert-Manager(w/ LetsEncrypt)
Client --> AWS NLB --> Nginx Ingress Controller (Handle Routing Logic and TLS Termination) --> Pods