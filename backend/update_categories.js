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

  console.log('Connected to database');

  // Add kategori column to produk table
  db.query('ALTER TABLE produk ADD COLUMN kategori VARCHAR(50) DEFAULT "food"', (err, results) => {
    if (err) {
      console.error('Error adding kategori column:', err);
      db.end();
      return;
    }
    console.log('Kategori column added successfully');

    // Now check current products
    db.query('SELECT id, nama FROM produk', (err, results) => {
      if (err) {
        console.error('Error querying products:', err);
        db.end();
        return;
      }
      console.log('Current products:');
      console.log(JSON.stringify(results, null, 2));

      // Update products with appropriate categories based on names
      const updatePromises = results.map(product => {
        return new Promise((resolve, reject) => {
          let kategori = 'food'; // default

          const nama = product.nama.toLowerCase();

          // Categorize based on product name
          if (nama.includes('latte') || nama.includes('espresso') || nama.includes('americano') ||
              nama.includes('kopi') || nama.includes('teh') || nama.includes('jus') ||
              nama.includes('soda') || nama.includes('minum')) {
            kategori = 'drinks';
          } else if (nama.includes('kentang') || nama.includes('onion') || nama.includes('ring') ||
                     nama.includes('snack') || nama.includes('keripik') || nama.includes('kacang') ||
                     nama.includes('permen') || nama.includes('coklat') || nama.includes('biskuit')) {
            kategori = 'snacks';
          }

          db.query('UPDATE produk SET kategori = ? WHERE id = ?', [kategori, product.id], (err, result) => {
            if (err) {
              reject(err);
            } else {
              console.log(`Updated ${product.nama} to category ${kategori}`);
              resolve(result);
            }
          });
        });
      });

      Promise.all(updatePromises)
        .then(() => {
          console.log('All products updated successfully');
          // Final check
          db.query('SELECT id, nama, kategori FROM produk', (err, finalResults) => {
            if (err) {
              console.error('Error final query:', err);
            } else {
              console.log('Final products with categories:');
              console.log(JSON.stringify(finalResults, null, 2));
            }
            db.end();
          });
        })
        .catch(err => {
          console.error('Error updating products:', err);
          db.end();
        });
    });
  });
});