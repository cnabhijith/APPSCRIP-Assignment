output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubeconfig" {
  value       = module.eks.kubeconfig
  description = "Kubeconfig for accessing the EKS cluster"
}
