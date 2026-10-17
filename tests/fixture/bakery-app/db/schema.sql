CREATE TABLE customers (id SERIAL PRIMARY KEY, phone TEXT UNIQUE NOT NULL, name TEXT);
CREATE TABLE orders (id SERIAL PRIMARY KEY, customer_id INT REFERENCES customers(id), total NUMERIC(10, 2), status TEXT, created_at TIMESTAMP DEFAULT now());
