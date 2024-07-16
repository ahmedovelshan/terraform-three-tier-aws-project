#!/bin/bash
set -e

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Install npm packages globally
sudo npm init -y
sudo npm install -y express mysql

# Install Apache and enable necessary modules
sudo apt update
sudo apt install -y apache2
sudo a2enmod proxy proxy_http

# Create the project directory
sudo mkdir -p /var/www/html/public
sudo chown $USER:$USER /var/www/html/public
cd /var/www/html/public

# Initialize npm project and install packages locally
npm init -y
npm install express mysql

# Create the Express server script
cat << 'EOF' > server.js
const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

// Create a connection to the RDS database
const db = mysql.createConnection({
    host: 'database-1.cp4oqcyy2y04.eu-central-1.rds.amazonaws.com',
    user: 'admin',
    password: '54hwlvg4Ipaf6218',
    port: 3306,
    database: 'mysql'
});

db.connect(err => {
    if (err) {
        console.error('Error connecting to the database:', err);
        return;
    }
    console.log('Connected to the RDS database');
});

// Endpoint to fetch tables from the database
app.get('/tables', (req, res) => {
    db.query('SHOW TABLES', (error, results) => {
        if (error) {
            res.status(500).send('Error fetching tables');
            return;
        }
        res.json(results);
    });
});

// Serve static files (e.g., HTML, CSS, client-side scripts)
app.use(express.static('public'));

app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
EOF

# Create the HTML file
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MySQL Tables Viewer</title>
</head>
<body>
    <h1>MySQL Tables Viewer</h1>
    <ul id="tables-list"></ul>

    <script>
        // Fetch tables from server
        fetch('/tables')
            .then(response => response.json())
            .then(data => {
                const tablesList = document.getElementById('tables-list');
                data.forEach(table => {
                    const li = document.createElement('li');
                    li.textContent = table['Tables_in_mysql']; // Adjust based on your response structure
                    tablesList.appendChild(li);
                });
            })
            .catch(error => console.error('Error fetching tables:', error));
    </script>
</body>
</html>
EOF

# Configure Apache
sudo bash -c 'cat <<EOT > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerName 172.31.17.224

    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    DocumentRoot /var/www/html/public
    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/my-node-app_error.log
    CustomLog \${APACHE_LOG_DIR}/my-node-app_access.log combined
</VirtualHost>
EOT'

# Start the Node.js server
nohup node server.js > server.log 2>&1 &

# Restart Apache to apply changes
sudo systemctl restart apache2
