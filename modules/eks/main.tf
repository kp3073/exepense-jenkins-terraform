resource "aws_eks_cluster" "main" {
  name     = "${var.env}-${var.project_name}"
  role_arn = aws_iam_role.main.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}


resource "null_resource" "aws-auth" {
  depends_on = [aws_eks_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}-${var.project_name}
aws-auth upsert --mapusers --userarn arn:aws:iam::471112727668:user/keyur --username keyu --groups system:masters
  EOF
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-${var.project_name}-eks-noad-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.size
    max_size     = var.size
    min_size     = var.size
  }
}

# resource "aws_eks_identity_provider_config" "main" {
#   cluster_name = aws_eks_cluster.main.name
#
#   oidc {
#     client_id                     = aws eks describe-cluster -- name $prod-expense --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5
#     identity_provider_config_name = "eks-config"
#     issuer_url                    = "your issuer_url"
#   }
# }
# output "eks" {
#   value = "aws eks describe-cluster -- name $prod-expense --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5"
# }

output "eks" {
  value = aws_eks_cluster.main
}