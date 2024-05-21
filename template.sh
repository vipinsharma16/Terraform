#!/bin/bash
            set -o xtrace
            /etc/eks/bootstrap.sh bmt-rat-eks
            /opt/aws/bin/cfn-signal --exit-code $? \
                     --resource EKSNodeGroup1  \
                     --region us-east-1 
