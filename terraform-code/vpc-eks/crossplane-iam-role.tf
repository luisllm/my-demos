resource "aws_iam_role" "test-crossplane-iam-role" {
  name  = "${local.system_name}-test-crossplane-iam-role"
  assume_role_policy = templatefile("templates/oidc_assume_role_policy.json", {
    OIDC_ARN  = module.eks.oidc_provider_arn,
    #OIDC_URL  = replace(module.eks_cluster.cluster_oidc_issuer_url.0.url, "https://", ""),
    OIDC_URL = module.eks.oidc_provider,
    NAMESPACE = "*",
    SA_NAME   = "system:serviceaccount:crossplane-system:provider-aws-*"
  })
  depends_on = [module.eks.oidc_provider]

  tags = merge(
    local.commontags,
    {
      "application" = "crossplane"
    }
  )
}

resource "aws_iam_role_policy_attachment" "s3-full-access-attachment" {
  role       = aws_iam_role.test-crossplane-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_ssm_parameter" "test-crossplane-iam-role-arn" {
  name        = "/${local.system_name}/test-crossplane-iam-role-arn"
  description = "IAM Role to be used by the ServiceAccount of Crossplane"
  type        = "String"
  value       = aws_iam_role.test-crossplane-iam-role.arn
  depends_on  = [aws_iam_role.test-crossplane-iam-role]
}