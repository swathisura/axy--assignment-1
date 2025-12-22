# -------------------------------
# 1. Launch Template
# -------------------------------
resource "aws_launch_template" "backend" {
  name_prefix   = "axy-backend-"
  image_id      = "ami-0c02fb55956c7d316"  # replace with your AMI
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
docker run -d -p 5000:5000 your-backend-image
EOF
  )

  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}

# -------------------------------
# 2. Security Group
# -------------------------------
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

# -------------------------------
# 3. Auto Scaling Group
# -------------------------------
resource "aws_autoscaling_group" "backend_asg" {
  name                 = "axy-backend-asg"
  max_size             = 3
  min_size             = 1
  desired_capacity     = 1
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]

  tag {
    key                 = "Name"
    value               = "axy-backend"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
}

# -------------------------------
# 4. Optional: Scaling Policy
# -------------------------------
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = aws_autoscaling_group.backend_asg.name
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "cpu-scale-down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = aws_autoscaling_group.backend_asg.name
}
