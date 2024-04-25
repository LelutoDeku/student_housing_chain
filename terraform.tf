provider "aws" {
  region = "us-east-1" # Specify your desired AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Specify the AMI ID of the instance
  instance_type = "t2.micro"              # Specify the instance type

  tags = {
    Name = "ExampleInstance"              # Specify a name for your instance
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"                   # Specify a name for the security group
  description = "Security group for web app"
  
  // Ingress rules (allow inbound traffic)
  ingress {
    from_port   = 80                        # Allow HTTP traffic
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]             # Allow traffic from anywhere
  }
  
  ingress {
    from_port   = 443                       # Allow HTTPS traffic
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // Egress rules (allow outbound traffic)
  egress {
    from_port   = 0                         # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web_sg"                        # Specify a name for the security group
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Specify the AMI ID of the instance
  instance_type = "t2.micro"              # Specify the instance type

  tags = {
    Name = "ExampleInstance"              # Specify a name for your instance
  }

  // Associate the security group with the EC2 instance
  security_groups = [aws_security_group.web_sg.name]
}
