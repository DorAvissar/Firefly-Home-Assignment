provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}


resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main-route-table"
  }
}


resource "aws_subnet" "main_sub" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet"
  }
}


resource "aws_route_table_association" "main_rt_assoc" {
  subnet_id      = aws_subnet.main_sub.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_security_group" "new_sg" {
  name        = "new_sg"
  description = "New security group created via AWS Console"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "main_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "main-security-group"
  description = "Security group for EC2 instance in main VPC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
        from_port   = 80  
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "main-sg"
  }
}


resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_kp" {
  key_name   = "demo-key-pair"
  public_key = tls_private_key.tls_key.public_key_openssh

  tags = {
    Name = "demo-key-pair"
  }
}


resource "local_file" "private_key" {
  filename        = "${path.module}/demo-kp.pem"
  content         = tls_private_key.tls_key.private_key_pem
  file_permission = "0400"
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "ec2-s3-policy"
  description = "Policy to allow EC2 to interact with S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.demo_bucket.arn,
          "${aws_s3_bucket.demo_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "demo_instance" {
  ami                         = "ami-037774efca2da0726"  
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main_sub.id
  vpc_security_group_ids       = [aws_security_group.new_sg.id]
  key_name                    = aws_key_pair.demo_kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "demo-instance"
    vendor = "Firefly"
  }
}


resource "random_id" "bucket_suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "demo-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_demo" {
  bucket = aws_s3_bucket.demo_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
