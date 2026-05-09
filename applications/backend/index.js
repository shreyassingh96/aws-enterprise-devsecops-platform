const express = require('express');
const { Pool } = require('pg');
const { createClient } = require('redis');
const winston = require('winston');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Structured Logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});

// Database Connection
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
});

// Redis Connection
const redisClient = createClient({
  url: `redis://${process.env.REDIS_HOST || 'localhost'}:6379`
});

redisClient.on('error', (err) => logger.error('Redis Client Error', err));

app.use(express.json());

app.get('/health', async (req, res) => {
  try {
    const dbRes = await pool.query('SELECT NOW()');
    res.status(200).json({ status: 'ok', db: 'connected', time: dbRes.rows[0].now });
  } catch (err) {
    logger.error('Health check failed', err);
    res.status(500).json({ status: 'error', error: err.message });
  }
});

app.get('/api/data', async (req, res) => {
  // Example endpoint utilizing cache
  const cacheKey = 'app_data';
  try {
    if (!redisClient.isOpen) await redisClient.connect();
    const cachedData = await redisClient.get(cacheKey);

    if (cachedData) {
      return res.json({ source: 'cache', data: JSON.parse(cachedData) });
    }

    const data = { message: "Hello from DevSecOps Backend" };
    await redisClient.setEx(cacheKey, 60, JSON.stringify(data));

    res.json({ source: 'db', data });
  } catch (error) {
    logger.error('API error', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.listen(port, () => {
  logger.info(`Backend listening at http://localhost:${port}`);
});
