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
      adminConn.end();

      // Now connect with database specified for app usage
      const appConfig = {
        host: DB_HOST,
        port: DB_PORT,
        user: DB_USER,
        password: DB_PASSWORD,
        database: DB_NAME,
        multipleStatements: false
      };

      db = mysql.createConnection(appConfig);
      db.connect((err) => {
        if (err) {
          console.error('Database connection failed:', err.message || err);
          return;
        }
        dbReady = true;
        console.log('Connected to MySQL database:', DB_NAME);
        startServer();
      });
    });
  });
}

initDatabaseAndConnect();

// Middleware: block requests until DB is ready
app.use((req, res, next) => {
  if (!dbReady) return res.status(503).json({ error: 'Database not ready' });
  next();
});

// Routes
app.get('/api/summary', (req, res) => {
  const query = `
    SELECT
      SUM(pendapatan) as total_pendapatan,
      SUM(keuntungan) as total_keuntungan,
      COUNT(*) as total_transaksi,
      SUM(pengeluaran) as total_pengeluaran
    FROM transaksi
    WHERE DATE(tanggal) = CURDATE()
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.get('/api/transaksi', (req, res) => {
  db.query('SELECT * FROM transaksi ORDER BY tanggal DESC', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/api/transaksi', (req, res) => {
  const { pendapatan, keuntungan, pengeluaran, deskripsi } = req.body;
  const query = 'INSERT INTO transaksi (pendapatan, keuntungan, pengeluaran, deskripsi) VALUES (?, ?, ?, ?)';
  db.query(query, [pendapatan, keuntungan, pengeluaran, deskripsi], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
});

app.get('/api/produk', (req, res) => {
  db.query('SELECT * FROM produk ORDER BY tanggal DESC', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/api/produk', (req, res) => {
  const { nama, harga, stok, deskripsi, gambar, kategori } = req.body;
  const query = 'INSERT INTO produk (nama, harga, stok, deskripsi, gambar, kategori) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [nama, harga, stok, deskripsi, gambar, kategori], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
});

app.put('/api/produk/:id', (req, res) => {
  const { id } = req.params;
  const { nama, harga, stok, deskripsi, gambar, kategori } = req.body;
  const query = 'UPDATE produk SET nama = ?, harga = ?, stok = ?, deskripsi = ?, gambar = ?, kategori = ? WHERE id = ?';
  db.query(query, [nama, harga, stok, deskripsi, gambar, kategori, id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Produk updated' });
  });
});

app.put('/api/produk/:id/stok', (req, res) => {
  const { id } = req.params;
  const { jumlah } = req.body;
  const query = 'UPDATE produk SET stok = stok - ? WHERE id = ? AND stok >= ?';
  db.query(query, [jumlah, id, jumlah], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.affectedRows === 0) return res.status(400).json({ error: 'Stok tidak cukup' });
    res.json({ message: 'Stok updated' });
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

      res.json({ message: 'Produk deleted' });
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
  const PORT = process.env.PORT || 3000;
  // Prevent multiple listeners
  if (app.listening) return;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}