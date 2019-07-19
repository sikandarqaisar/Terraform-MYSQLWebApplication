resource "aws_instance" "db" {
    ami = "${var.ami}"
    instance_type = "t2.micro"
    subnet_id = "${var.privateSubnet_id}"
    vpc_security_group_ids = ["${var.DBSecurityGroup}"]
    associate_public_ip_address = false
    source_dest_check = false
    user_data = <<-EOF
                #!/bin/bash
                set -x
                sleep 30
                apt-get -y update
                apt-get install mysql-server -y
                apt-get install php-mysql -y
                ufw enable 
                ufw allow mysql
                ufw allow ssh
                systemctl restart ufw 
                systemctl start mysql
                systemctl enable mysql
                sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
                mysql -u root 
                mysql -u root -e "CREATE DATABASE sikandar;"
                mysql -u root -e "USE sikandar;"
                mysql -u root -e "CREATE USER 'sikandar'@'%' IDENTIFIED BY 'sikandar';"
                mysql -u root -e "GRANT ALL PRIVILEGES ON * . * TO 'sikandar'@'%';"
                mysql -u root -e "FLUSH PRIVILEGES;"
                mysql -u root -e "exit;"
                mysql -u sikandar -psikandar ;
                mysql -u sikandar -psikandar -e "USE sikandar;"
                mysql -u sikandar -psikandar << EOFA 
                USE sikandar;
                CREATE TABLE users (
                id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,firstname VARCHAR(30) NOT NULL,lastname VARCHAR(30) NOT NULL,email VARCHAR(50) NOT NULL,age INT(3),location VARCHAR(50),date TIMESTAMP );
                exit;
                EOFA
                systemctl restart mysql
                
                EOF
    key_name = "sikandarKeypair-ohio"


    tags ={
        Name = "DBInstance"
    }
}


resource "aws_launch_configuration" "autoscale_launch" {
    image_id= "${var.ami}"
    instance_type = "t2.micro"
    key_name = "sikandarKeypair-ohio"
    security_groups = ["${var.securityGroup_webapp_instances}"]
    user_data = <<-EOF
                #!/bin/sh
                apt-get update
                sudo apt install -y apache2
                apt-get install mysql-server -y      
                apt-get install php-mysql -y
                apt-get install php libapache2-mod-php -y
                apt-get install zip -y
                cd /var/www
                rm -rf html
                wget https://s3.amazonaws.com/alamkey/html1.zip
                unzip html1.zip
                sed -i -e 's/localhost/${aws_instance.db.private_ip}/g' /var/www/html/config.php
                EOF
}

resource "aws_autoscaling_group" "autoscale_group" {
  launch_configuration = "${aws_launch_configuration.autoscale_launch.id}"
  vpc_zone_identifier = ["${var.publicSubnet_id}","${var.privateSubnet_id}",]  
  min_size = 2
  max_size = 2
  tag {
    key = "Name"
    value = "autoscale"
    propagate_at_launch = true
  }
}



resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = "${aws_lb_target_group.alb_target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
}



resource "aws_lb" "alb" {  
  name            = "alb"  
  subnets         = ["${var.publicSubnet_id}","${var.privateSubnet_id}"]
  security_groups = ["${var.securityGroup_webapp_albs}"]
  internal        = false 
  idle_timeout    = 60   
  tags = {    
    Name    = "alb"    
  }   
}

resource "aws_lb_target_group" "alb_target_group" {  
  name     = "alb-target-group"  
  port     = "80"  
  protocol = "HTTP"  
  vpc_id   = "${var.vpc_id}"   
  tags = {    
    Name = "alb_target_group"    
  }   
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = true 
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 80
  }
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.alb.arn}"  
  port              = 80  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

