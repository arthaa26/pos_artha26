const mysql = require('mysql2');

const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'pos_artha26'
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to database:', err);
    return;
  }

  // Insert sample transaction
  const query = `
    INSERT INTO transaksi (pendapatan, keuntungan, pengeluaran, deskripsi, items, paymentMethod, cashGiven, \`change\`)
    VALUES (50000, 10000, 0, 'Penjualan kopi', '[{\"nama\":\"Espresso\",\"harga\":15000,\"qty\":2}]', 'cash', 50000, 20000)
  `;

  db.query(query, (err, result) => {
    if (err) {
      console.error('Error inserting transaction:', err);
    } else {
      console.log('Sample transaction added successfully');
    }
    db.end();
  });
});