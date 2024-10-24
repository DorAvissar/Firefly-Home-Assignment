# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "firefly_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy to Allow Access to S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "firefly_s3_policy"
  description = "IAM policy for EC2 access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::firefly-bucket-${random_string.suffix.result}",
          "arn:aws:s3:::firefly-bucket-${random_string.suffix.result}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}


# Instance Profile to associate the IAM role with EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "firefly_ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
