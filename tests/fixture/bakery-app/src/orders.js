// Orders: customers order ahead; the bakery marks them ready; customers pick up.
const db = require('./db');

async function createOrder(customerId, items) {
  const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  return db.query('INSERT INTO orders (customer_id, total, status) VALUES ($1, $2, $3) RETURNING id', [customerId, total, 'placed']);
}

async function markReady(orderId) {
  return db.query('UPDATE orders SET status = $1 WHERE id = $2', ['ready', orderId]);
}

module.exports = { createOrder, markReady };
