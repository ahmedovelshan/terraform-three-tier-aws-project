#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx awscli
sudo systemctl start nginx
sudo systemctl enable nginx

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install 

# Variables for S3 bucket and directories
s3_bucket=$(terraform output bucket_arn)
document_directory="/var/www/html/documents"

# Create the directories
sudo mkdir -p $document_directory

# Sync images and documents from S3 bucket to the respective directories
sudo aws s3 sync s3://$s3_bucket/ $document_directory/

# Get hostname and IP address
hostname=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')

# Create HTML content
html_content="<html lang='en'>
<head><title>Content</title></head>
<body>
<h1>Documents!</h1></br>
<h3>(Instance Content)</h3>
<p>Hostname: $hostname</p>
<p>IP Address: $ip_address</p>
<h3>Documents</h3>
<div>"


# Add document links to HTML content
for document in $document_directory/*; do
    html_content="$html_content<li><a href='/documents/$(basename $document)'>$(basename $document)</a></li>"
done

html_content="$html_content</ul>
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
          location /documents/ {
              alias /var/www/html/documents/;
              autoindex on;
          }
          location / {
              try_files $uri $uri/ =404;
          }
      }' | sudo tee /etc/nginx/sites-available/default

sudo systemctl restart nginx
