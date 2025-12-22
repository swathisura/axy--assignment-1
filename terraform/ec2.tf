#!/bin/bash

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application directory
mkdir -p /opt/axy-app
cd /opt/axy-app

# Create docker-compose.yml for production
cat << EOF > docker-compose.yml
version: '3.8'

services:
  backend:
    image: node:18-alpine
    container_name: axy-backend
    working_dir: /app
    environment:
      DB_HOST: ${db_host}
      DB_PORT: ${db_port}
      DB_NAME: ${db_name}
      DB_USER: ${db_username}
      DB_PASSWORD: ${db_password}
    volumes:
      - ./backend:/app
    command: >
      sh -c "npm install &&
             node server.js"
    ports:
      - "3000:3000"

  frontend:
    image: nginx:alpine
    container_name: axy-frontend
    volumes:
      - ./frontend/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./frontend:/usr/share/nginx/html
    ports:
      - "80:80"
    depends_on:
      - backend
EOF

# Clone your application code (or copy from S3/CodeCommit)
# For now, we'll create a simple version

# Create backend directory
mkdir -p backend
cat << 'EOF' > backend/package.json
{
  "name": "axy-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0"
  }
}
EOF

# Create backend server.js
cat << 'EOF' > backend/server.js
const express = require('express');
const { Pool } = require('pg');
const app = express();
const port = 3000;

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

app.use(express.json());

app.get('/api/health', async (req, res) => {
  try {
    const client = await pool.connect();
    client.release();
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', error: err.message });
  }
});

app.get('/api/message', async (req, res) => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        text TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    await pool.query(
      "INSERT INTO messages (text) VALUES ('Hello from EC2 Auto Scaling!')"
    );
    
    const result = await pool.query(
      'SELECT text, created_at FROM messages ORDER BY created_at DESC LIMIT 1'
    );
    
    res.json({
      message: result.rows[0]?.text || 'Welcome!',
      timestamp: result.rows[0]?.created_at || new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(\`Backend running on port \${port}\`);
});
EOF

# Create frontend directory
mkdir -p frontend
cat << 'EOF' > frontend/nginx.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

cat << 'EOF' > frontend/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Axy DevOps - EC2</title>
    <style>
        body { font-family: Arial; max-width: 800px; margin: 0 auto; padding: 20px; }
        .container { background: #fff; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .card { background: #f8f9fa; padding: 15px; margin: 15px 0; border-radius: 5px; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Axy DevOps - EC2 Auto Scaling</h1>
        <div class="card">
            <h3>Backend Status</h3>
            <div id="status">Checking...</div>
        </div>
        <div class="card">
            <h3>Database Message</h3>
            <p id="message">Click to fetch message</p>
            <button onclick="fetchMessage()">Get Message</button>
        </div>
    </div>
    <script>
        async function fetchMessage() {
            const el = document.getElementById('message');
            el.innerHTML = 'Fetching...';
            try {
                const response = await fetch('/api/message');
                const data = await response.json();
                el.innerHTML = \`<strong>\${data.message}</strong><br><small>\${new Date(data.timestamp).toLocaleString()}</small>\`;
            } catch (err) {
                el.innerHTML = 'Error fetching message';
            }
        }
        fetch('/api/health').then(r => r.json()).then(data => {
            document.getElementById('status').innerHTML = \`✓ Healthy - \${data.timestamp}\`;
        });
    </script>
</body>
</html>
EOF

# Start Docker Compose
cd /opt/axy-app
docker-compose up -d

# Install CloudWatch Agent (optional)
yum install -y amazon-cloudwatch-agent
