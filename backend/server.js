require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'database',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'axydb',
  user: process.env.DB_USER || 'axyuser',
  password: process.env.DB_PASSWORD || 'axypass'
});

// Test database connection
async function testDbConnection() {
  try {
    const client = await pool.connect();
    console.log('Database connected successfully');
    client.release();
  } catch (err) {
    console.error('Database connection error:', err.message);
  }
}

// Middleware
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'backend-api'
  });
});

app.get('/api/message', async (req, res) => {
  try {
    // Create messages table if not exists
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        text TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insert a sample message
    await pool.query(
      'INSERT INTO messages (text) VALUES ($1) ON CONFLICT DO NOTHING',
      ['Hello from Axy DevOps!']
    );

    // Get latest message
    const result = await pool.query(
      'SELECT text, created_at FROM messages ORDER BY created_at DESC LIMIT 1'
    );

    res.json({
      message: result.rows[0]?.text || 'No messages yet',
      timestamp: result.rows[0]?.created_at || new Date().toISOString(),
      source: 'database'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(port, async () => {
  console.log(`Backend API running on port ${port}`);
  await testDbConnection();
});
