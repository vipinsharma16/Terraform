resource "aws_launch_template" "EKSWorkerNodeLaunchTemplateCiscoAMI" {
    depends_on = [ aws_eks_cluster.bmt-rat-eks ]
    image_id                             = var.AMIId
    instance_type                        = var.NodeInstanceType
    name                                 = "EKSWorkerNodeLaunchTemplateCiscoAMI"
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
    
    user_data = filebase64("${path.module}/template.sh")
}