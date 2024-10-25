resource "aws_eks_cluster" "main" {
  name     = "${var.env}-${var.project_name}"
  role_arn = aws_iam_role.main.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}


resource "aws_iam_role" "main" {
  name = "${var.env}-${var.project_name}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.main.name
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