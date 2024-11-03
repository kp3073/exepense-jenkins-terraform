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
    aws-auth upsert --mapusers --userarn arn:aws:iam::471112727668:user/keyur --username keyur --groups system:masters
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

