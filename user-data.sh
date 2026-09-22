#!/bin/bash

set -e

# Update packages
apt-get update -y

# Install Nginx
apt-get install -y nginx

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Get VM information
HOSTNAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Create custom Nginx page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Azure Linux VM</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .container {
            background: white;
            width: 600px;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            text-align: center;
        }

        h1 {
            color: #0078d4;
        }

        .info {
            margin: 20px 0;
            padding: 15px;
            background: #f4f6f8;
            border-radius: 8px;
            font-size: 18px;
        }

        .label {
            font-weight: bold;
        }
    </style>
</head>

<body>

<div class="container">

    <h1>Azure Linux VM</h1>

    <div class="info">
        <span class="label">Hostname:</span>
        $HOSTNAME
    </div>

    <div class="info">
        <span class="label">Private IP:</span>
        $PRIVATE_IP
    </div>

    <p>Nginx is running successfully.</p>

</div>

</body>
</html>
EOF

# Restart Nginx
systemctl restart nginx

echo "Nginx installation completed successfully."