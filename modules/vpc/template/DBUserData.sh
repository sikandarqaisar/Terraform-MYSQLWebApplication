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
          mysql -u root -e "CREATE DATABASE testdb;"
          mysql -u root -e "USE testdb;"
          mysql -u root -e "CREATE USER 'test'@'%' IDENTIFIED BY 'sikandar';"
          mysql -u root -e "GRANT ALL PRIVILEGES ON * . * TO 'test'@'%';"
          mysql -u root -e "FLUSH PRIVILEGES;"
          mysql -u root -e "exit;"
          mysql -u test -psikandar ;
          mysql -u test -psikandar -e "USE testdb;"
          mysql -u test -psikandar << EOF 
          USE testdb;
          CREATE TABLE users (
          id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,firstname VARCHAR(30) NOT NULL,lastname VARCHAR(30) NOT NULL,email VARCHAR(50) NOT NULL,age INT(3),location VARCHAR(50),date TIMESTAMP );
          exit;
          EOF
          systemctl restart mysql