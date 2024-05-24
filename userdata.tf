
locals {
  eks-node-private-userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash -xe
/etc/eks/bootstrap.sh '${var.EKSClusterName}' --apiserver-endpoint '${aws_eks_cluster.bmt-rat-eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.bmt-rat-eks.certificate_authority[0].data}' --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0e87fae068ae8d4e0' --dns-cluster-ip 10.100.0.10 --use-max-pods false
--region us-east-1 
--==MYBOUNDARY==--
USERDATA
}