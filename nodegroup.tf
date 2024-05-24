resource "aws_eks_node_group" "EKSNodegroup1" {
  cluster_name    = var.EKSClusterName
  node_group_name = var.NodegroupNameBMT
  node_role_arn   = aws_iam_role.EKSWorkerNodeRole.arn
  launch_template {
    id = aws_launch_template.EKSWorkerNodeLaunchTemplateCiscoAMI.id
    version = aws_launch_template.EKSWorkerNodeLaunchTemplateCiscoAMI.latest_version
  }
  subnet_ids      = [
    aws_subnet.PrivateSubnet01.id,
    aws_subnet.PrivateSubnet02.id,
  ]
  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  
  depends_on = [aws_launch_template.EKSWorkerNodeLaunchTemplateCiscoAMI]

    tags = {
    key = "kubernetes.io/cluster/bmt-rat-eks"
    value = "owned"
  }
}

resource "aws_eks_node_group" "EKSNodegroup2" {
  cluster_name    = var.EKSClusterName
  node_group_name = var.NodegroupNameRAT
  node_role_arn   = aws_iam_role.EKSWorkerNodeRole.arn
    
  launch_template {
    id = aws_launch_template.EKSWorkerNodeLaunchTemplateCiscoAMI.id
    version = aws_launch_template.EKSWorkerNodeLaunchTemplateCiscoAMI.latest_version
  }
  subnet_ids      = [
    aws_subnet.PrivateSubnet01.id,
    aws_subnet.PrivateSubnet02.id,
  ]
  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [aws_eks_node_group.EKSNodegroup1]

  tags = {
    key = "kubernetes.io/cluster/bmt-rat-eks"
    value = "owned"
  }
}