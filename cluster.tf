#eks cluster role & policy attached.
resource "aws_iam_role" "bmtRatEKSClusterRole" {
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "eks.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    force_detach_policies = false
    managed_policy_arns   = [
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
		"arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    ]
    max_session_duration  = 3600
    name                  = var.EKSControlPlaneRoleName
}


#eks worker node role & policy attached.
resource "aws_iam_role" "EKSWorkerNodeRole" {
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    force_detach_policies = false
    managed_policy_arns   = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ]
    name                  = var.EKSWorkerNodeRoleName
}


#EkS cluster creation
resource "aws_eks_cluster" "bmt-rat-eks" {
  name     = var.EKSClusterName
  role_arn = aws_iam_role.bmtRatEKSClusterRole.arn
  version = var.EKSVersion

#    enabled_cluster_log_types = [
#    "api",
#    "audit",
#    "authenticator",
#    "controllerManager",
#    "scheduler",
#  ]

  vpc_config {
    endpoint_private_access   = false
    endpoint_public_access    = true
    security_group_ids = [aws_security_group.ControlPlaneSecurityGroup.id]
    subnet_ids = [
        aws_subnet.PublicSubnet01.id, 
        aws_subnet.PublicSubnet02.id, 
        aws_subnet.PrivateSubnet01.id, 
        aws_subnet.PrivateSubnet02.id
    ]
  }
}

output "endpoint" {
  value = aws_eks_cluster.bmt-rat-eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.bmt-rat-eks.certificate_authority[0].data
}

output "identity-oidc-issuer" {
  value = aws_eks_cluster.bmt-rat-eks.identity[0].oidc[0].issuer
}

resource "aws_eks_addon" "coredns" {
    addon_name               = "coredns"
    addon_version            = var.EKSCoreDnsAddOnVersion
    cluster_name             = "bmt-rat-eks"
    resolve_conflicts_on_create = "OVERWRITE"
    depends_on = [aws_eks_cluster.bmt-rat-eks]
}

resource "aws_eks_addon" "kube-proxy" {
    addon_name               = "kube-proxy"
    addon_version            = var.EKSKubeProxyAddOnVersion
    cluster_name             = "bmt-rat-eks"
    depends_on = [aws_eks_cluster.bmt-rat-eks]
}

resource "aws_eks_addon" "vpc-cni" {
    addon_name               = "vpc-cni"
    addon_version            = var.EKSVpcCniAddOnVersion
    cluster_name             = "bmt-rat-eks"
    resolve_conflicts_on_create = "OVERWRITE"
    depends_on = [aws_eks_cluster.bmt-rat-eks]
}

resource "aws_iam_instance_profile" "WorkerNodesInstanceProfile" {
  name = "WorkerNodesInstanceProfile"
  role = var.EKSWorkerNodeRoleName
}
