resource "aws_launch_template" "backend" {
  name_prefix   = "axy-backend"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y docker
systemctl enable docker
systemctl start docker
sleep 10
docker run -d -p 5000:5000 your-backend-image
EOF
  )

  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}

