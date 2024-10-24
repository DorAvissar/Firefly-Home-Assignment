# Instance Security group (traffic ALB -> EC2, ssh -> EC2)
resource "aws_security_group" "ec2" {
  name        = "ec2_security_group"                          # The name of the security group
  description = "Security group for EC2 instance in main VPC" # Describes the purpose of the security group
  vpc_id      = aws_vpc.firefly_vpc.id                        # Associates the security group with the specified VPC

  ingress {
    cidr_blocks = [
      "0.0.0.0/0" # Allows incoming traffic from any IP address
    ]
    from_port = 22    # Allows traffic on port 22 (SSH)
    to_port   = 22    # Specifies the destination port (SSH)
    protocol  = "tcp" # The protocol to use (TCP in this case)
  }
  ingress { # these was added as part of part 2 task 1. 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP from anywhere
  }

  egress {
    from_port   = 0             # Allows all outbound traffic
    to_port     = 0             # All destination ports
    protocol    = -1            # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound traffic to any IP
  }
}


resource "aws_security_group" "new_sg" {
  name        = "new-ec2-security-group"
  description = "The Security group for part 2 task 3"
  vpc_id      = aws_vpc.firefly_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0" # Allows incoming traffic from any IP address
    ]
    from_port = 22    # Allows traffic on port 22 (SSH)
    to_port   = 22    # Specifies the destination port (SSH)
    protocol  = "tcp" # The protocol to use (TCP in this case)
  }
  ingress { # these was added as part of part 2 task 1. 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP from anywhere
  }

  egress {
    from_port   = 0             # Allows all outbound traffic
    to_port     = 0             # All destination ports
    protocol    = -1            # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound traffic to any IP
  }
}
