# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}AlbSecurityGroup"
  description = "Allow HTTP from Internet"
  vpc_id      = var.vpc_id

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
    Name = "${var.name_prefix}AlbSecurityGroup"
  }
}

# EC2 Security Group
resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}Ec2SecurityGroup"
  description = "Allow traffic from ALB + SSH from My IP"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App from ALB (8080)"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # SourceSecurityGroupId 相当
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ip_from_internet]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}Ec2SecurityGroup"
  }
}
# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}RdsSecurityGroup"
  description = "Allow DB access from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}RdsSecurityGroup"
  }
}
