CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO messages (text) 
VALUES ('Welcome to Axy DevOps Application')
ON CONFLICT DO NOTHING;
