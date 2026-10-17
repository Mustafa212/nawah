// Customers sign up with a phone number; repeat customers are not tracked yet.
const db = require('./db');

async function signUp(phone, name) {
  return db.query('INSERT INTO customers (phone, name) VALUES ($1, $2) RETURNING id', [phone, name]);
}

module.exports = { signUp };
