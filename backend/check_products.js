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

  // Check current products
  db.query('SELECT id, nama, kategori FROM produk ORDER BY id', (err, results) => {
    if (err) {
      console.error('Error querying products:', err);
      db.end();
      return;
    }
    console.log('Current products:');
    results.forEach(product => {
      console.log(`${product.id}: ${product.nama} - ${product.kategori}`);
    });

    // Reset Taro Late back to original if it was changed
    const taroLate = results.find(p => p.nama === 'Test Product Updated');
    if (taroLate) {
      console.log('\nResetting Taro Late back to original...');
      db.query('UPDATE produk SET nama = ?, kategori = ? WHERE id = ?',
        ['Taro Late', 'drinks', taroLate.id], (err, result) => {
          if (err) {
            console.error('Error resetting product:', err);
          } else {
            console.log('Product reset successfully');
          }
          db.end();
        });
    } else {
      db.end();
    }
  });
});