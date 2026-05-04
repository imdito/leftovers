const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Konfigurasi Database
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
};

let pool;

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
// ROUTE: PLACES NEARBY
// ==========================================
app.get('/api/places/nearby', async (req, res) => {
    const { lat, lng, category, radius = 3000 } = req.query;

    if (!lat || !lng || !category) {
        return res.status(400).json({
            success: false,
            message: 'Parameter lat, lng, dan category wajib diisi'
        });
    }

    try {
        const query = `
            SELECT *, 
                (6371000 * acos(
                    cos(radians(?)) * cos(radians(latitude)) *
                    cos(radians(longitude) - radians(?)) +
                    sin(radians(?)) * sin(radians(latitude))
                )) AS distance_meters
            FROM places
            WHERE is_active = TRUE
                AND category = ?
            HAVING distance_meters <= ?
            ORDER BY distance_meters ASC
            LIMIT 20
        `;

        const [rows] = await pool.execute(query, [lat, lng, lat, category, radius]);
        res.json({ success: true, data: rows });

    } catch (error) {
        console.error('Nearby Places Error:', error);
        res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
    }
});

// ==========================================
// MIDDLEWARE: VERIFIKASI JWT TOKEN (hanya satu!)
// ==========================================
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Akses ditolak. Token tidak ditemukan.' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Token tidak valid atau sudah kedaluwarsa.' });
        }
        req.user = user;
        next();
    });
};

// ==========================================
// ROUTE: REGISTER
// ==========================================
app.post('/api/register', async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Semua kolom harus diisi' });
    }

    try {
        const [existingUsers] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(409).json({ message: 'Email sudah terdaftar' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

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
        const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        const user = users[0];

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        const token = jwt.sign(
            { id: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        res.json({
            message: 'Login berhasil',
            token: token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                profile_photo: user.profile_photo
            }
        });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
});

// ==========================================
// ROUTE: UPDATE PROFILE PHOTO
// ==========================================
app.put('/api/profile/update-photo', authenticateToken, async (req, res) => {
    const { profile_photo } = req.body;

    if (!profile_photo) {
        return res.status(400).json({ message: 'ID Foto (Appwrite) tidak ditemukan' });
    }

    try {
        await pool.query(
            'UPDATE users SET profile_photo = ? WHERE id = ?',
            [profile_photo, req.user.id]
        );

        res.json({
            message: 'Foto profil berhasil diperbarui',
            profile_photo: profile_photo
        });
    } catch (error) {
        console.error('Update Photo Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
});

// ==========================================
// ROUTE: PING TEST
// ==========================================
app.get('/api/ping', (req, res) => {
    res.json({ message: "Halo! HP dan Server sudah terhubung 🚀" });
});

// Jalankan Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server Leftovers berjalan di port ${PORT}`);
});