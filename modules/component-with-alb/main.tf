resource "aws_security_group" "instance" {  
    
  name = "${var.component}-${var.env}-instance"


    egress {
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
    tags = {
        Name = "${var.component}-${var.env}-instance"
    }
}
resource "aws_security_group" "alb" {  
    
  name = "${var.component}-${var.env}-alb"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.component}-${var.env}-alb"
    }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.component}-${var.env}-"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.instance.id, aws_security_group.alb.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.component}-${var.env}"
    }
  }
}


resource "aws_autoscaling_group" "main" {
  availability_zones = [ "us-east-1a", "us-east-1b" ]
  name                      = "${var.component}-${var.env}"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_min_size
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "${var.component}-${var.env}"
  port     = var.lb["port"]
  protocol = "HTTP"

}
resource "aws_alb" "main" {
  name            = "${var.component}-${var.env}"
  internal        = var.lb["lb_internal"]
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets         = var.subnets
  tags = {
    Name = "${var.component}-${var.env}"
  }
  
}
resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.component}-${var.env}.${var.dns_domain}"
  type    = "CNAME"
  ttl     = 30
  records = [aws_alb.main.dns_name]  
}

# resource "null_resource" "ansible" {

#   provisioner "remote-exec" {
#     connection {
#       type     = "ssh"
#       host     = aws_instance.main.private_ip
#       user     = "ec2-user"
#       password = "DevOps321"
#     }
#     inline = [
#       "sudo labauto ansible",
#       "ansible-pull -i localhost, -U https://github.com/nikkaushal/wmp-ansible-templates-v3.git main.yml -e env=${var.env} -e COMPONENT=${var.component}"
#     ]
#   }
# } 
