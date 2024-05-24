resource "aws_launch_template" "EKSWorkerNodeLaunchTemplateCiscoAMI" {
    depends_on = [ aws_eks_cluster.bmt-rat-eks ]
    image_id                             = var.AMIId
    instance_type                        = var.NodeInstanceType
    name                                 = "${var.EKSClusterName}-node-launch-template"
    key_name = "eks-key"

    block_device_mappings {
        device_name  = "/dev/xvda"
        ebs {
            delete_on_termination = "true"
            volume_size           = var.EBSVolumeSize
            volume_type           = "gp2"
        }
    }

   network_interfaces {
     device_index = 0
     security_groups = [aws_security_group.ControlPlaneSecurityGroup.id]
   }

    metadata_options {
        http_put_response_hop_limit = 2
    }

    lifecycle {
    create_before_destroy = true
  }
    
    user_data = base64encode(local.eks-node-private-userdata)
}