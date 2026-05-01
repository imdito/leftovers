const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Konfigurasi Database (Nilainya diambil dari docker-compose.yml)
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
};

let pool;

// Inisiasi Koneksi Database
async function initDb() {
    try {
        pool = mysql.createPool(dbConfig);
        console.log('✅ Berhasil terhubung ke database MySQL');
    } catch (error) {
        console.error('❌ Gagal terhubung ke database:', error);
    }
}
initDb();

// ==========================================
// ROUTE: REGISTER
// ==========================================
app.post('/api/register', async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Semua kolom harus diisi' });
    }

    try {
        // Cek apakah email sudah terdaftar
        const [existingUsers] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(409).json({ message: 'Email sudah terdaftar' });
        }

        // Hash password menggunakan bcrypt
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Simpan user ke database
        const [result] = await pool.query(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
            [name, email, hashedPassword]
        );

        res.status(201).json({
            message: 'Registrasi berhasil',
            user: { id: result.insertId, name, email }
        });
    } catch (error) {
        console.error('Register Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
});

// ==========================================
// ROUTE: LOGIN
// ==========================================
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email dan password harus diisi' });
    }

    try {
        // Cari user berdasarkan email
        const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        const user = users[0];

        // Cocokkan password yang diinput dengan hash di database
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        // Buat JWT Token
        const token = jwt.sign(
            { id: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '1d' } // Token berlaku 7 hari
        );

        res.json({
            message: 'Login berhasil',
            token: token,
            user: { id: user.id, name: user.name, email: user.email }
        });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
});

// Jalankan Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server Leftovers berjalan di port ${PORT}`);
});