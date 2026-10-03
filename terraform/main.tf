# • 1 EC2 instance
# • 1 Security Group allowing SSH (22) and HTTP (80)
# • Output the EC2 public IP
# • Use variables for AWS region and instance type
# • Use a data source to retrieve the latest Ubuntu AMI


# EC2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id] 
  key_name               = "my-aws-key"

  tags = {
    Name = "aws-ec2"
  }
}

# --- SECURITY GROUP ---
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}