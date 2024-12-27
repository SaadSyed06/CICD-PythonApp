# Output EKS Cluster ID
output "eks_cluster_id" {
  description = "The EKS cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

# Output EC2 instance public IPs
output "ec2_instance_public_ips" {
  description = "The public IPs of the Ubuntu EC2 instances"
  value       = aws_instance.ubuntu_instance[*].public_ip
}

# Output EC2 instance private IPs
output "ec2_instance_private_ips" {
  description = "The private IPs of the Ubuntu EC2 instances"
  value       = aws_instance.ubuntu_instance[*].private_ip
}

# Output VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}