resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AmazonEKS_ALB_Controller_Policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = data.aws_iam_policy_document.alb_controller.json
}

data "aws_iam_policy_document" "alb_controller" {
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "waf-regional:*",
      "wafv2:*",
      "tag:GetTags",
      "tag:TagResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "alb_controller_role" {
  name = "eks-alb-controller-role"

  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume.json
}

data "aws_iam_policy_document" "alb_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }
  }
}