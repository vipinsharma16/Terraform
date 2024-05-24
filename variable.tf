variable "vpc_cidr" {
  type = string
  default = "192.168.0.0/16"
  description = "The CIDR range for the VPC. This should be a valid private (RFC 1918) CIDR range"
}

variable "PublicSubnet01Block" {
  type = string
  default = "192.168.0.0/18"
  description = "CidrBlock for public subnet 01 within the VPC"
}

variable "PublicSubnet02Block" {
  type = string
  default = "192.168.64.0/18"
  description = "CidrBlock for public subnet 02 within the VPC"
}

variable "PrivateSubnet01Block" {
  type = string
  default = "192.168.128.0/18"
  description = "CidrBlock for private subnet 01 within the VPC"
}

variable "PrivateSubnet02Block" {
  type = string
  default = "192.168.192.0/18"
  description = "CidrBlock for private subnet 02 within the VPC"
}

variable "NodegroupNameBMT" {
  type = string
  description = "BMT worker node group name"
  default = "bmt-ng-eks"
  
}

variable "NodegroupNameRAT" {
  type = string
  description = "RAT worker node group name"
  default = "RAT-ng-eks"
  
}

variable "EKSKubeProxyAddOnVersion" {
  type = string
  description = "EKS Kube proxy Addon Version"
  default = "v1.29.1-eksbuild.2"
  
}

variable "EKSVpcCniAddOnVersion" {
  type = string
  description = "EKS VPC CNI Addon Version"
  default = "v1.18.1-eksbuild.3"
  
}

variable "EKSCoreDnsAddOnVersion" {
  type = string
  description = "EKS Core DNS Addon Version"
  default = "v1.11.1-eksbuild.4"
  
}

variable "EKSVersion" {
  type = string
  description = "EKS Version"
  default = "1.29"
  
}

variable "NodeInstanceType" {
  type = string
  description = "EC2 WorkerNode Type"
  default = "t3.medium"
}

variable "EBSVolumeSize" {
  type = string
  description = "EBS Volume Size"
  default = 20
}

variable "EKSControlPlaneRoleName" {
  type = string
  description = "EKS control plane Role Name"
  default = "bmtRatEKSClusterRole"
  
}

variable "EKSWorkerNodeRoleName" {
  type = string
  description = "EKS Worker Node Role Name"
  default = "AmazonEKSNodeRole"
  
}

variable "EKSClusterName" {
  type = string
  description = "EKS Cluster Name"
  default = "bmt-rat-eks"
  
}

variable "AMIId" {
  type = string
  description = "Nodes AMI"
  default = "ami-0e87fae068ae8d4e0"
}

