resource "aws_launch_template" "backend" {
  name_prefix   = "axy-backend"
  image_id      = "ami-0c02fb55956c7d316"   # Amazon Linux 2 AMI
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker awscli
    systemctl enable docker
    systemctl start docker

    # Login to ECR
    $(aws ecr get-login --no-include-email --region ${var.aws_region})

    # Pull and run the Docker image
    docker pull ${var.ecr_repository_url}:latest
    docker run -d -p 5000:5000 ${var.ecr_repository_url}:latest
  EOF
  )

  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}

