resource "aws_instance" "ec2" {
  ami                         = var.ami_id                          # The Amazon Machine Image (AMI) ID for the instance
  instance_type               = var.instance_type                   # Specifies the EC2 instance type (e.g., t2.micro)
  key_name                    = var.key_pair_name                   # The key pair name used for SSH access
  subnet_id                   = aws_subnet.firefly-public-subnet.id # Specifies the subnet ID for the instance (public subnet)
  vpc_security_group_ids      = [aws_security_group.new_sg.id]      # Use this instead of security_groups
  associate_public_ip_address = true                                # Ensures the EC2 instance gets a public IP address for internet access
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name


  tags = {
    Name   = "${var.ec2_instance_name}-instance" # Tags the instance with a name for identification
    Vendor = "Firefly"                           # these tag was added as part of part 2 task 1. 
  }

}
