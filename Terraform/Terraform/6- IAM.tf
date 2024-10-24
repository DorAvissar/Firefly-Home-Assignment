# IAM Role for EC2 instance
# This role allows the EC2 instance to assume permissions defined in the attached policies.
resource "aws_iam_role" "ec2_role" {
  name = "firefly_ec2_role"

  # The assume_role_policy specifies which service (EC2) is allowed to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # EC2 service can assume this role
        }
        Action = "sts:AssumeRole"  # Permission to assume the role using STS
      }
    ]
  })
}

# This policy grants permissions for the EC2 instance to interact with the S3 bucket.
resource "aws_iam_policy" "s3_access_policy" {
  name        = "firefly_s3_policy"  # Name of the IAM policy
  description = "IAM policy for EC2 access to S3 bucket"  # Brief description

  # JSON-encoded policy specifying the allowed actions and resources for S3 access.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"  # Grant access permissions
        Action = [
          "s3:ListBucket",  # List bucket contents
          "s3:GetObject",    # Retrieve objects from the bucket
          "s3:PutObject"     # Upload objects to the bucket
        ]
        Resource = [
          "arn:aws:s3:::firefly-bucket-${random_string.suffix.result}",      # Access to the bucket itself
          "arn:aws:s3:::firefly-bucket-${random_string.suffix.result}/*"     # Access to all objects within the bucket
        ]
      }
    ]
  })
}


# This resource attaches the S3 access policy to the EC2 IAM role.
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name  # Role to which the policy is attached
  policy_arn = aws_iam_policy.s3_access_policy.arn  # ARN of the S3 access policy
}


# The instance profile allows the EC2 instance to assume the IAM role.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "firefly_ec2_profile"  # Name of the instance profile
  role = aws_iam_role.ec2_role.name  # IAM role associated with the instance profile
}

# This policy allows the EC2 instance to communicate with Systems Manager.
resource "aws_iam_role_policy_attachment" "ssm_ec2" {
  role       = aws_iam_role.ec2_role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  
}
