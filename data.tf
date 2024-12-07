data "aws_iam_policy_document" "dynamoDB_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeImport",
      "dynamodb:ConditionCheckItem",
      "dynamodb:DescribeContributorInsights",
      "dynamodb:Scan",
      "dynamodb:ListTagsOfResource",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeGlobalTableSettings",
      "dynamodb:PartiQLSelect",
      "dynamodb:DescribeTable",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeGlobalTable",
      "dynamodb:GetItem",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeExport",
      "dynamodb:GetResourcePolicy",
      "dynamodb:DescribeKinesisStreamingDestination",
      "dynamodb:DescribeBackup",
      "dynamodb:GetRecords",
      "dynamodb:DescribeTableReplicaAutoScaling"
    ]
    resources = ["arn:aws:dynamodb:ap-southeast-1:255945442255:table/${var.name_prefix}-bookinventory"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:ListContributorInsights",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:ListGlobalTables",
      "dynamodb:ListTables",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListBackups",
      "dynamodb:GetAbacStatus",
      "dynamodb:ListImports",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeEndpoints",
      "dynamodb:ListExports",
      "dynamodb:ListStreams"
    ]
    resources = ["*"]
  }
}

data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["*shared*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}