const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const multer = require('multer');
const bcrypt = require('bcrypt');
const { OAuth2Client } = require('google-auth-library');
require('dotenv').config({ path: './config/.env' });

const app = express();
app.use(cors());
app.use(express.json());
const fs = require('fs');
const path = require('path');

// Global error handler for uncaught exceptions - MUST BE BEFORE ANYTHING ELSE
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  console.error('Stack:', err.stack);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('SIGINT', () => {
  console.log('\n👋 Received SIGINT, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n👋 Received SIGTERM, shutting down...');
  process.exit(0);
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage });
app.use('/uploads', express.static('uploads'));

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const DB_HOST = process.env.DB_HOST || '127.0.0.1';
const DB_PORT = process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306;
const DB_USER = process.env.DB_USER || 'root';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'pos_artha26';

// We'll initialize the database from init.sql (if necessary) using an admin connection
let db; // actual connection used by routes
let dbReady = false;
let serverRunning = false;

const initSqlPath = path.join(__dirname, 'init.sql');

function initDatabaseAndConnect() {
  const adminConfig = {
    host: DB_HOST,
    port: DB_PORT,
    user: DB_USER,
    password: DB_PASSWORD,
    multipleStatements: true
  };

  const adminConn = mysql.createConnection(adminConfig);
  adminConn.connect((err) => {
    if (err) {
      console.error('Admin DB connection failed:', err.message || err);
      console.error('Ensure Laragon MySQL is running and credentials in backend/.env are correct.');
      return;
    }

    // Read and execute init.sql to create database and tables if missing
    let sql = '';
    try {
      sql = fs.readFileSync(initSqlPath, 'utf8');
    } catch (e) {
      console.error('Failed reading init.sql:', e.message || e);
      adminConn.end();
      return;
    }

    adminConn.query(sql, (err) => {
      if (err) {
        console.error('Error running init.sql:', err.message || err);
        adminConn.end();
        return;
      }
      console.log('Database initialized or already present.');
      
      // Run migration.sql
      const migrationSqlPath = path.join(__dirname, 'migration.sql');
      let migrationSql = '';
      try {
        migrationSql = fs.readFileSync(migrationSqlPath, 'utf8');
      } catch (e) {
        console.warn('migration.sql not found, skipping:', e.message);
      }
      
      if (migrationSql) {
        adminConn.query(migrationSql, (err) => {
          if (err) {
            console.warn('Warning running migration.sql:', err.message);
          } else {
            console.log('Migration completed successfully.');
          }
          adminConn.end();
          connectAppDatabase();
        });
      } else {
        adminConn.end();
        connectAppDatabase();
      }
    });
  });
}

function connectAppDatabase() {
  // Now connect with database specified for app usage
  const appConfig = {
    host: DB_HOST,
    port: DB_PORT,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    multipleStatements: false
  };

  console.log('🔌 Attempting to connect to:', DB_HOST + ':' + DB_PORT + '/' + DB_NAME);
  db = mysql.createConnection(appConfig);
  
  db.on('error', (err) => {
    console.error('❌ Database error:', err.message);
  });
  
  db.connect((err) => {
    if (err) {
      console.error('❌ Database connection failed:', err.message || err);
      console.error('Config:', { host: DB_HOST, port: DB_PORT, user: DB_USER, database: DB_NAME });
      process.exit(1);
    }
    dbReady = true;
    console.log('✅ Connected to MySQL database:', DB_NAME);
    startServer();
  });
}

initDatabaseAndConnect();

// Middleware: block requests until DB is ready
app.use((req, res, next) => {
  try {
    console.log('⏳ Request:', req.method, req.path);
    if (!dbReady) {
      console.log('❌ Database not ready');
      return res.status(503).json({ error: 'Database not ready' });
    }
    next();
  } catch (err) {
    console.error('❌ Middleware error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Routes with defensive try-catch
app.get('/api/test', (req, res) => {
  try {
    console.log('📍 GET /api/test called');
    return res.json({ 
      status: 'ok', 
      message: 'Server is working',
      database: dbReady ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('❌ /api/test error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Debug endpoint for connectivity testing
app.get('/api/debug', (req, res) => {
  try {
    const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    console.log('🔍 Debug from:', clientIp);
    return res.json({
      server: {
        status: 'running',
        database: dbReady ? 'connected' : 'disconnected',
        port: 3000
      },
      client: {
        ip: clientIp,
        userAgent: req.headers['user-agent']
      },
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.get('/api/summary', (req, res) => {
  try {
    console.log('📊 GET /api/summary called');
    const query = `
      SELECT
        COALESCE(total_penjualan, 0) as total_pendapatan,
        COALESCE(keuntungan, 0) as total_keuntungan,
        COALESCE(jumlah_transaksi, 0) as total_transaksi,
        COALESCE(total_pengeluaran, 0) as total_pengeluaran,
        COALESCE(net_profit, 0) as net_profit
      FROM ringkasan_harian
      WHERE tanggal = CURDATE()
    `;
    db.query(query, (err, results) => {
      if (err) {
        console.error('❌ Summary query error:', err);
        return res.status(500).json({ error: err.message });
      }
      // Return default if no data
      const data = results[0] || {
        total_pendapatan: 0,
        total_keuntungan: 0,
        total_transaksi: 0,
        total_pengeluaran: 0,
        net_profit: 0
      };
      res.json(data);
    });
  } catch (err) {
    console.error('❌ /api/summary error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.get('/api/transaksi', (req, res) => {
  const query = `
    SELECT 
      pn.id,
      pn.no_referensi,
      pn.tanggal,
      pn.total_harga as pendapatan,
      pn.total_modal,
      pn.keuntungan,
      pn.metode_pembayaran as paymentMethod,
      pn.uang_diterima as cashGiven,
      pn.kembalian as change,
      pn.catatan as deskripsi,
      pn.status,
      COALESCE(GROUP_CONCAT(
        JSON_OBJECT(
          'id', dp.produk_id,
          'nama', dp.nama_produk,
          'harga', dp.harga_satuan,
          'qty', dp.jumlah,
          'subtotal', dp.subtotal
        )
      ), '[]') as items
    FROM penjualan pn
    LEFT JOIN detail_penjualan dp ON pn.id = dp.penjualan_id
    WHERE pn.status = 'selesai'
    GROUP BY pn.id
    ORDER BY pn.tanggal DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    console.log('Fetched transaksi:', results.length, 'records');
    // Parse items JSON
    results.forEach(row => {
      if (row.items) {
        try {
          row.items = JSON.parse('[' + row.items + ']');
        } catch (e) {
          row.items = [];
        }
      } else {
        row.items = [];
      }
    });
    res.json(results);
  });
});

app.post('/api/transaksi', (req, res) => {
  console.log('Received transaksi:', req.body);
  const { items, metode_pembayaran, uang_diterima, kembalian, catatan } = req.body;
  
  // Validasi items
  if (!items || items.length === 0) {
    return res.status(400).json({ error: 'Tidak ada item dalam transaksi' });
  }

  // Calculate totals
  let total_harga = 0;
  let total_modal = 0;
  items.forEach(item => {
    total_harga += (item.harga || 0) * (item.qty || 0);
    total_modal += ((item.harga_modal || 0) * (item.qty || 0));
  });
  const keuntungan = total_harga - total_modal;

  // Buat nomor referensi
  const no_referensi = 'POS-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + Date.now();

  const insertPenjualanQuery = `
    INSERT INTO penjualan (
      no_referensi, tanggal, total_harga, total_modal, keuntungan,
      metode_pembayaran, uang_diterima, kembalian, catatan, status
    ) VALUES (?, NOW(), ?, ?, ?, ?, ?, ?, ?, 'selesai')
  `;

  db.query(
    insertPenjualanQuery,
    [no_referensi, total_harga, total_modal, keuntungan, metode_pembayaran, uang_diterima, kembalian, catatan],
    (err, result) => {
      if (err) {
        console.error('Error inserting penjualan:', err);
        return res.status(500).json({ error: err.message });
      }

      const penjualan_id = result.insertId;
      console.log('Inserted penjualan with id:', penjualan_id);

      // Insert detail penjualan
      const insertDetailQuery = `
        INSERT INTO detail_penjualan (
          penjualan_id, produk_id, nama_produk, harga_satuan, 
          harga_modal_satuan, jumlah, subtotal, modal
        ) VALUES ?
      `;

      const detailValues = items.map(item => [
        penjualan_id,
        item.id || null,
        item.nama || '',
        item.harga || 0,
        item.harga_modal || 0,
        item.qty || 1,
        (item.harga || 0) * (item.qty || 1),
        (item.harga_modal || 0) * (item.qty || 1)
      ]);

      db.query(insertDetailQuery, [detailValues], (err, result) => {
        if (err) {
          console.error('Error inserting detail penjualan:', err);
          return res.status(500).json({ error: err.message });
        }

        console.log('Inserted detail penjualan:', result.affectedRows, 'items');
        res.json({ id: penjualan_id, no_referensi });
      });
    }
  );
});

app.get('/api/produk', (req, res) => {
  const query = `
    SELECT 
      p.id,
      p.nama,
      p.harga,
      COALESCE(p.harga_modal, 0) as harga_modal,
      p.stok,
      p.stok_minimal,
      p.deskripsi,
      p.gambar,
      p.kategori_id,
      COALESCE(kp.nama, 'Lainnya') as kategori,
      p.is_active,
      p.created_at,
      p.updated_at
    FROM produk p
    LEFT JOIN kategori_produk kp ON p.kategori_id = kp.id
    WHERE p.is_active = TRUE
    ORDER BY p.nama ASC
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('❌ Error querying produk:', err.message);
      console.error('Query:', query);
      return res.status(500).json({ error: err.message });
    }
    console.log('✅ Found', results.length, 'products');
    res.json(results);
  });
});

app.post('/api/produk', (req, res) => {
  const { nama, harga, harga_modal, stok, stok_minimal, deskripsi, gambar, kategori } = req.body;
  
  // Validate required fields
  if (!nama || harga === undefined || stok === undefined) {
    return res.status(400).json({ error: 'nama, harga, and stok are required' });
  }
  
  // Find kategori_id from kategori name
  const kategoriQuery = 'SELECT id FROM kategori_produk WHERE nama = ? LIMIT 1';
  db.query(kategoriQuery, [kategori || 'Lainnya'], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    
    const kategori_id = results.length > 0 ? results[0].id : 4; // Default to 'Lainnya' (id 4)
    
    const query = `
      INSERT INTO produk (nama, harga, harga_modal, stok, stok_minimal, deskripsi, gambar, kategori_id, is_active)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE)
    `;
    db.query(query, [nama, harga || 0, harga_modal || 0, stok || 0, stok_minimal || 0, deskripsi || '', gambar || '', kategori_id], (err, result) => {
      if (err) {
        console.error('Insert error:', err);
        return res.status(500).json({ error: err.message });
      }
      console.log('✅ Product inserted with ID:', result.insertId);
      res.status(201).json({ id: result.insertId });
    });
  });
});

app.put('/api/produk/:id', (req, res) => {
  const { id } = req.params;
  const { nama, harga, harga_modal, stok, stok_minimal, deskripsi, gambar, kategori } = req.body;
  
  // Find kategori_id from kategori name
  const kategoriQuery = 'SELECT id FROM kategori_produk WHERE nama = ? LIMIT 1';
  db.query(kategoriQuery, [kategori || 'Lainnya'], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    
    const kategori_id = results.length > 0 ? results[0].id : 4;
    
    const query = `
      UPDATE produk 
      SET nama = ?, harga = ?, harga_modal = ?, stok = ?, stok_minimal = ?, 
          deskripsi = ?, gambar = ?, kategori_id = ?, updated_at = NOW()
      WHERE id = ?
    `;
    db.query(query, [nama, harga || 0, harga_modal || 0, stok || 0, stok_minimal || 0, deskripsi || '', gambar || '', kategori_id, id], (err, result) => {
      if (err) {
        console.error('Update error:', err);
        return res.status(500).json({ error: err.message });
      }
      console.log('✅ Product updated:', id);
      res.json({ message: 'Produk updated' });
    });
  });
});

app.put('/api/produk/:id/stok', (req, res) => {
  const { id } = req.params;
  const { jumlah } = req.body;
  
  // Check current stok
  const checkQuery = 'SELECT stok FROM produk WHERE id = ?';
  db.query(checkQuery, [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: 'Produk tidak ditemukan' });
    if (results[0].stok < jumlah) return res.status(400).json({ error: 'Stok tidak cukup' });
    
    // Update stok
    const updateQuery = 'UPDATE produk SET stok = stok - ?, updated_at = NOW() WHERE id = ?';
    db.query(updateQuery, [jumlah, id], (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: 'Stok updated' });
    });
  });
});

// ===== KATEGORI ENDPOINTS =====

app.get('/api/kategori-produk', (req, res) => {
  db.query('SELECT id, nama, deskripsi FROM kategori_produk ORDER BY nama', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.get('/api/kategori-pengeluaran', (req, res) => {
  db.query('SELECT id, nama, deskripsi FROM kategori_pengeluaran ORDER BY nama', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// ===== PENGELUARAN ENDPOINTS =====

app.get('/api/pengeluaran', (req, res) => {
  const query = `
    SELECT 
      pg.id,
      pg.kategori_id,
      pg.kategori_nama,
      pg.jumlah,
      pg.deskripsi,
      pg.tanggal,
      pg.status,
      kp.nama as kategori
    FROM pengeluaran pg
    LEFT JOIN kategori_pengeluaran kp ON pg.kategori_id = kp.id
    WHERE DATE(pg.tanggal) = CURDATE()
    ORDER BY pg.tanggal DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/api/pengeluaran', (req, res) => {
  const { jumlah, deskripsi, kategori_nama, kategori_id } = req.body;
  
  if (!jumlah || jumlah <= 0) {
    return res.status(400).json({ error: 'Jumlah pengeluaran harus lebih dari 0' });
  }

  const query = `
    INSERT INTO pengeluaran (kategori_id, kategori_nama, jumlah, deskripsi, tanggal, status)
    VALUES (?, ?, ?, ?, NOW(), 'tercatat')
  `;
  
  db.query(query, [kategori_id || null, kategori_nama || 'Lainnya', jumlah, deskripsi || ''], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
});

// ===== LAPORAN ENDPOINTS =====

app.get('/api/laporan/harian', (req, res) => {
  const query = `
    SELECT 
      tanggal,
      total_penjualan,
      jumlah_transaksi,
      total_modal,
      keuntungan,
      total_pengeluaran,
      net_profit
    FROM ringkasan_harian
    WHERE tanggal >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    ORDER BY tanggal DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.get('/api/laporan/top-produk', (req, res) => {
  const query = `
    SELECT 
      p.id,
      p.nama,
      SUM(dp.jumlah) as terjual,
      SUM(dp.subtotal) as revenue,
      SUM(dp.subtotal - dp.modal) as profit
    FROM detail_penjualan dp
    JOIN produk p ON dp.produk_id = p.id
    JOIN penjualan pn ON dp.penjualan_id = pn.id
    WHERE DATE(pn.tanggal) = CURDATE()
    GROUP BY p.id, p.nama
    ORDER BY revenue DESC
    LIMIT 10
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.get('/api/laporan/stok-alert', (req, res) => {
  const query = `
    SELECT 
      id,
      nama,
      stok,
      stok_minimal,
      (stok_minimal - stok) as perlu_restock
    FROM produk
    WHERE stok <= stok_minimal AND is_active = TRUE
    ORDER BY perlu_restock DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Delete product and its uploaded image (if any)
app.delete('/api/produk/:id', (req, res) => {
  const { id } = req.params;
  // Find product to get gambar path
  db.query('SELECT gambar FROM produk WHERE id = ?', [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: 'Produk tidak ditemukan' });
    const gambar = results[0].gambar;

    // Delete DB record
    db.query('DELETE FROM produk WHERE id = ?', [id], (err, result) => {
      if (err) return res.status(500).json({ error: err.message });

      // Try to remove uploaded file if it exists locally
      if (gambar) {
        try {
          // gambar might be saved as a full URL or a relative path. Normalize to filename.
          let filename = null;
          const uploadsSegment = '/uploads/';
          if (gambar.includes(uploadsSegment)) {
            filename = gambar.substring(gambar.indexOf(uploadsSegment) + uploadsSegment.length);
          } else {
            // could be just a filename or a relative path
            filename = path.basename(gambar);
          }
          if (filename) {
            const filepath = path.join(__dirname, 'uploads', filename);
            fs.unlink(filepath, (err) => {
              if (err && err.code !== 'ENOENT') console.error('Failed to delete image file:', err.message || err);
            });
          }
        } catch (e) {
          console.error('Error while deleting image file:', e.message || e);
        }
      }

      res.status(200).json({ message: 'Produk deleted' });
    });
  });
});

app.post('/upload', upload.single('gambar'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  res.json({ url: `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` });
});

app.post('/register', async (req, res) => {
  const { username, password, phone } = req.body;
  // Check if user already exists
  const checkQuery = 'SELECT COUNT(*) as count FROM users';
  db.query(checkQuery, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results[0].count > 0) return res.status(400).json({ error: 'Only one account allowed' });
    bcrypt.hash(password, 10, (err, hashedPassword) => {
      if (err) return res.status(500).json({ error: err.message });
      const insertQuery = 'INSERT INTO users (username, password, phone) VALUES (?, ?, ?)';
      db.query(insertQuery, [username, hashedPassword, phone], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'User registered' });
      });
    });
  });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const query = 'SELECT * FROM users WHERE username = ? OR phone = ?';
  db.query(query, [username, username], async (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(401).json({ error: 'User not found' });
    const user = results[0];
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) return res.status(401).json({ error: 'Invalid password' });
    res.json({ message: 'Login successful' });
  });
});

app.post('/google-login', async (req, res) => {
  const { idToken, email } = req.body;
  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    // Check if user exists
    const query = 'SELECT * FROM users WHERE username = ?';
    db.query(query, [email], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      if (results.length === 0) {
        // Check total users
        const countQuery = 'SELECT COUNT(*) as count FROM users';
        db.query(countQuery, (err, countResults) => {
          if (err) return res.status(500).json({ error: err.message });
          if (countResults[0].count > 0) return res.status(400).json({ error: 'Only one account allowed' });
          // Create new user
          const insertQuery = 'INSERT INTO users (username, password) VALUES (?, ?)';
          db.query(insertQuery, [email, ''], (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ message: 'Login successful' });
          });
        });
      } else {
        res.json({ message: 'Login successful' });
      }
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.get('/users', (req, res) => {
  const query = 'SELECT id, username FROM users';
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/users', async (req, res) => {
  const { username, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  const query = 'INSERT INTO users (username, password) VALUES (?, ?)';
  db.query(query, [username, hashedPassword], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
});

function startServer() {
  if (serverRunning) {
    console.log('⚠️  Server already running, skipping');
    return;
  }
  
  const PORT = process.env.PORT || 3000;
  try {
    // Listen on 0.0.0.0 to accept connections from emulator and other hosts
    const server = app.listen(PORT, '0.0.0.0', () => {
      serverRunning = true;
      console.log('🚀 Server listening on 0.0.0.0:' + PORT);
      console.log('📝 API available at:');
      console.log('   - Localhost: http://127.0.0.1:' + PORT);
      console.log('   - Android Emulator: http://10.0.2.2:' + PORT);
      console.log('   - External: http://<YOUR_PC_IP>:' + PORT);
    });
    
    server.on('error', (err) => {
      console.error('❌ Server error:', err.message);
      process.exit(1);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err.message);
    process.exit(1);
  }
}