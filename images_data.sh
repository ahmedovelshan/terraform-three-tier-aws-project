#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx awscli
sudo systemctl start nginx
sudo systemctl enable nginx

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Variables for S3 bucket and image directory
s3_bucket=$(terraform output bucket_arn)
image_directory="/var/www/html/images"

# Create the image directory
sudo mkdir -p $image_directory

# Sync images from S3 bucket to the image directory
sudo aws s3 sync s3://$s3_bucket/ $image_directory/

# Get hostname and IP address
hostname=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')

# Create HTML content
html_content="<html lang='en'>
<head><title>Images</title></head>
<body>
<h1>Images!</h1></br>
<h3>(Instance Images)</h3>
<p>Hostname: $hostname</p>
<p>IP Address: $ip_address</p>
<div>"

# Add image tags to HTML content
for image in $image_directory/*; do
    html_content="$html_content<img src='/images/$(basename $image)' alt='Instance Image' style='width:200px;height:200px;'/>"
done

html_content="$html_content</div>
</body>
</html>"

# Write HTML content to index.html
echo "$html_content" | sudo tee /var/www/html/index.html

# Configure Nginx server block
echo 'server {
          listen 80 default_server;
          listen [::]:80 default_server;
          root /var/www/html;
          index index.html index.htm index.nginx-debian.html;
          server_name _;
          location /images/ {
              alias /var/www/html/images/;
              autoindex on;
          }
          location / {
              try_files $uri $uri/ =404;
          }
      }' | sudo tee /etc/nginx/sites-available/default

sudo systemctl restart nginx
