variable "env" {
    default = "staging"
}

variable "region" {
    default = "us-east-1"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "zone" {
    default = ["us-east-1a", "us-east-1b"]
}

variable "subnet_cidr" {
    default = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
}

variable "eks_name" {
    default = "demo"
}

variable "eks_version" {
    default = "1.30"
}

