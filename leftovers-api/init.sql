CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_photo VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE PLACES
-- ============================================
CREATE TABLE IF NOT EXISTS places (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category ENUM('supermarket', 'donation', 'warung') NOT NULL,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    phone VARCHAR(50) NULL,
    opening_hours VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DATA SUPERMARKET / TOKO / MARKET
-- ============================================
INSERT INTO places (name, category, address, city, latitude, longitude, phone, opening_hours) VALUES

-- === JOGJA - SUPERMARKET ===
('Superindo Gejayan', 'supermarket', 'Jl. Affandi No.1, Mrican, Caturtunggal, Depok', 'Yogyakarta', -7.77012300, 110.38741200, '(0274) 584200', 'Senin-Minggu 07:00-22:00'),
('Superindo Godean', 'supermarket', 'Jl. Godean No.48, Sidoarum, Godean', 'Yogyakarta', -7.78543100, 110.32156700, '(0274) 798123', 'Senin-Minggu 07:00-22:00'),
('Superindo Seturan', 'supermarket', 'Jl. Seturan Raya No.5, Caturtunggal, Depok', 'Yogyakarta', -7.76234500, 110.39876500, '(0274) 485123', 'Senin-Minggu 07:00-22:00'),
('Superindo Bantul', 'supermarket', 'Jl. Jend. Sudirman No.10, Bantul', 'Yogyakarta', -7.88234100, 110.32987600, '(0274) 367234', 'Senin-Minggu 07:00-22:00'),
('Superindo Ringroad Utara', 'supermarket', 'Jl. Ring Road Utara No.12, Condongcatur', 'Yogyakarta', -7.75123400, 110.38654300, '(0274) 885321', 'Senin-Minggu 07:00-22:00'),

('Indomaret Malioboro', 'supermarket', 'Jl. Malioboro No.18, Gedongtengen', 'Yogyakarta', -7.79234500, 110.36543200, '(0274) 512345', 'Senin-Minggu 06:00-23:00'),
('Indomaret Gejayan', 'supermarket', 'Jl. Affandi No.5, Mrican, Caturtunggal', 'Yogyakarta', -7.77234100, 110.38912300, '(0274) 584567', 'Senin-Minggu 06:00-23:00'),
('Indomaret Kaliurang', 'supermarket', 'Jl. Kaliurang KM 5, Sleman', 'Yogyakarta', -7.75876500, 110.39123400, '(0274) 883456', 'Senin-Minggu 06:00-23:00'),
('Indomaret Selokan Mataram', 'supermarket', 'Jl. Selokan Mataram No.22, Sinduadi', 'Yogyakarta', -7.76543200, 110.37654300, '(0274) 623456', 'Senin-Minggu 06:00-23:00'),
('Indomaret Timoho', 'supermarket', 'Jl. Kenari No.8, Timoho, Umbulharjo', 'Yogyakarta', -7.79876500, 110.37987600, '(0274) 564321', 'Senin-Minggu 06:00-23:00'),

('Alfamart Condongcatur', 'supermarket', 'Jl. Anggajaya No.3, Condongcatur, Depok', 'Yogyakarta', -7.75432100, 110.39234500, '(0274) 886543', 'Senin-Minggu 06:00-23:00'),
('Alfamart Godean', 'supermarket', 'Jl. Godean KM 4, Sidokarto', 'Yogyakarta', -7.79123400, 110.31876500, '(0274) 791234', 'Senin-Minggu 06:00-23:00'),
('Alfamart Bantul', 'supermarket', 'Jl. Parangtritis No.5, Bantul', 'Yogyakarta', -7.87543200, 110.32123400, '(0274) 368765', 'Senin-Minggu 06:00-23:00'),
('Alfamart Wonosari', 'supermarket', 'Jl. Wonosari No.9, Piyungan', 'Yogyakarta', -7.82345600, 110.45678900, '(0274) 496789', 'Senin-Minggu 06:00-23:00'),
('Alfamart Kota Baru', 'supermarket', 'Jl. Cik Di Tiro No.4, Terban, Gondokusuman', 'Yogyakarta', -7.78456700, 110.37234500, '(0274) 521234', 'Senin-Minggu 06:00-23:00'),

('Carrefour / Trans Mart Mataram City', 'supermarket', 'Jl. Ring Road Barat, Nogotirto, Gamping', 'Yogyakarta', -7.78901200, 110.33456700, '(0274) 625432', 'Senin-Minggu 10:00-22:00'),
('Mirota Kampus', 'supermarket', 'Jl. C. Simanjuntak No.70, Terban', 'Yogyakarta', -7.78234500, 110.37123400, '(0274) 566789', 'Senin-Minggu 08:00-21:00'),
('Lotte Mart Yogyakarta', 'supermarket', 'Jl. Babarsari No.1, Caturtunggal, Depok', 'Yogyakarta', -7.76789000, 110.40234500, '(0274) 485432', 'Senin-Minggu 09:00-22:00'),
('Farmers Market Jogja City Mall', 'supermarket', 'Jl. Magelang No.18, Sindurejan', 'Yogyakarta', -7.77654300, 110.35678900, '(0274) 622345', 'Senin-Minggu 10:00-21:30'),
('Toko Progo', 'supermarket', 'Jl. A. Yani No.39, Ngupasan, Gondomanan', 'Yogyakarta', -7.80123400, 110.36543200, '(0274) 374321', 'Senin-Sabtu 08:00-20:00'),

-- === KLATEN - SUPERMARKET ===
('Superindo Klaten', 'supermarket', 'Jl. Pemuda No.10, Klaten Tengah', 'Klaten', -7.70678900, 110.59876500, '(0272) 321234', 'Senin-Minggu 07:00-22:00'),
('Indomaret Klaten Kota', 'supermarket', 'Jl. Diponegoro No.5, Klaten Tengah', 'Klaten', -7.70543200, 110.60123400, '(0272) 322345', 'Senin-Minggu 06:00-23:00'),
('Indomaret Prambanan', 'supermarket', 'Jl. Solo-Yogya KM 16, Prambanan', 'Klaten', -7.75234500, 110.49123400, '(0274) 497321', 'Senin-Minggu 06:00-23:00'),
('Indomaret Delanggu', 'supermarket', 'Jl. Raya Delanggu No.8, Delanggu', 'Klaten', -7.63456700, 110.65987600, '(0272) 551234', 'Senin-Minggu 06:00-23:00'),
('Alfamart Klaten Utara', 'supermarket', 'Jl. Raya Klaten-Solo No.3, Klaten Utara', 'Klaten', -7.69876500, 110.60456700, '(0272) 323456', 'Senin-Minggu 06:00-23:00'),
('Alfamart Ceper', 'supermarket', 'Jl. Raya Ceper No.12, Ceper', 'Klaten', -7.69123400, 110.62345600, '(0272) 556789', 'Senin-Minggu 06:00-23:00'),
('Alfamart Wedi', 'supermarket', 'Jl. Wedi-Bayat No.5, Wedi', 'Klaten', -7.76543200, 110.61234500, '(0272) 491234', 'Senin-Minggu 06:00-23:00'),
('Sri Ratu Praja Klaten', 'supermarket', 'Jl. Pemuda No.25, Klaten Tengah', 'Klaten', -7.70789000, 110.59654300, '(0272) 321789', 'Senin-Sabtu 08:00-20:00'),
('Toko Segar Klaten', 'supermarket', 'Jl. dr. Wahidin No.7, Klaten Tengah', 'Klaten', -7.70456700, 110.60345600, '(0272) 324321', 'Senin-Sabtu 07:00-19:00'),
('Laris Swalayan', 'supermarket', 'Jl. Manisrenggo No.4, Prambanan', 'Klaten', -7.74567800, 110.48765400, '(0274) 496543', 'Senin-Minggu 07:00-21:00');

-- ============================================
-- DATA DONASI MAKANAN
-- ============================================
INSERT INTO places (name, category, address, city, latitude, longitude, phone, opening_hours) VALUES

-- === JOGJA - DONASI ===
('Yayasan Rumah Zakat Yogyakarta', 'donation', 'Jl. Kenari No.14, Muja Muju, Umbulharjo', 'Yogyakarta', -7.80234500, 110.37654300, '(0274) 562345', 'Senin-Jumat 08:00-16:00'),
('LAZISMU Yogyakarta', 'donation', 'Jl. KHA Dahlan No.103, Ngampilan', 'Yogyakarta', -7.80123400, 110.36234500, '(0274) 377432', 'Senin-Jumat 08:00-16:00'),
('LAZ DOMPET DHUAFA Yogyakarta', 'donation', 'Jl. Kyai Mojo No.56, Bener, Tegalrejo', 'Yogyakarta', -7.78345600, 110.35123400, '(0274) 623789', 'Senin-Jumat 08:00-16:00'),
('Rumah Singgah Ahmad Dahlan', 'donation', 'Jl. Sisingamangaraja No.5, Karangkajen', 'Yogyakarta', -7.82123400, 110.37456700, '(0274) 374567', 'Setiap Hari 08:00-17:00'),
('Food Bank Jogja (FBJ)', 'donation', 'Jl. Imogiri Timur KM 8, Giwangan', 'Yogyakarta', -7.83456700, 110.38234500, '0812-2700-0123', 'Senin-Sabtu 09:00-15:00'),
('Yayasan Peduli Kasih Jogja', 'donation', 'Jl. Parangtritis KM 3, Sewon, Bantul', 'Yogyakarta', -7.83876500, 110.33456700, '0878-3456-7890', 'Senin-Sabtu 08:00-16:00'),
('Masjid Gedhe Kauman - Dapur Umum', 'donation', 'Jl. Kauman No.1, Ngupasan, Gondomanan', 'Yogyakarta', -7.80234500, 110.36123400, '(0274) 376543', 'Setiap Hari 07:00-17:00'),
('GKJ Gondokusuman - Diakonia Sosial', 'donation', 'Jl. Dr. Wahidin No.9, Terban', 'Yogyakarta', -7.78567800, 110.37345600, '(0274) 566432', 'Senin-Jumat 08:00-14:00'),
('Lembaga Amil Zakat UII', 'donation', 'Jl. Kaliurang KM 14, Ngaglik, Sleman', 'Yogyakarta', -7.69876500, 110.39765400, '(0274) 898432', 'Senin-Jumat 08:00-16:00'),
('Dapur Berbagi Jogja', 'donation', 'Jl. Veteran No.9, Semaki, Umbulharjo', 'Yogyakarta', -7.79654300, 110.37987600, '0813-2876-5432', 'Senin-Sabtu 10:00-14:00'),
('BAZNAS Kota Yogyakarta', 'donation', 'Jl. Kenari No.56, Muja Muju, Umbulharjo', 'Yogyakarta', -7.80456700, 110.37876500, '(0274) 562789', 'Senin-Jumat 08:00-15:30'),
('Yayasan Al-Ikhlas Sleman', 'donation', 'Jl. Magelang KM 7, Mlati, Sleman', 'Yogyakarta', -7.74321000, 110.34567800, '(0274) 869432', 'Senin-Sabtu 08:00-16:00'),
('Komunitas Nasi Bungkus Jogja', 'donation', 'Jl. Monjali No.22, Sinduadi, Mlati', 'Yogyakarta', -7.75432100, 110.36234500, '0815-7654-3210', 'Sabtu-Minggu 06:00-09:00'),
('PKPU Human Initiative Yogyakarta', 'donation', 'Jl. Gedongkuning No.25, Rejowinangun', 'Yogyakarta', -7.81234500, 110.38765400, '(0274) 454321', 'Senin-Jumat 08:00-16:00'),
('Panti Asuhan Putra Muhammadiyah', 'donation', 'Jl. Monginsidi No.7, Cokrodiningratan', 'Yogyakarta', -7.78765400, 110.35987600, '(0274) 561234', 'Setiap Hari 08:00-17:00'),

-- === KLATEN - DONASI ===
('BAZNAS Kabupaten Klaten', 'donation', 'Jl. Pemuda No.2, Klaten Tengah', 'Klaten', -7.70345600, 110.59765400, '(0272) 321567', 'Senin-Jumat 08:00-15:00'),
('Lazismu Klaten', 'donation', 'Jl. KH Ahmad Dahlan No.5, Klaten Tengah', 'Klaten', -7.70567800, 110.59987600, '(0272) 322678', 'Senin-Jumat 08:00-15:30'),
('Yayasan Rumah Zakat Klaten', 'donation', 'Jl. Merbabu No.19, Klaten Tengah', 'Klaten', -7.70678900, 110.60234500, '(0272) 323789', 'Senin-Jumat 08:00-16:00'),
('Panti Asuhan Al-Hikmah Klaten', 'donation', 'Jl. Seruni No.8, Klaten Utara', 'Klaten', -7.69765400, 110.60543200, '(0272) 324890', 'Setiap Hari 07:00-17:00'),
('Masjid Agung Klaten - Sosial', 'donation', 'Jl. Pemuda No.1, Klaten Tengah', 'Klaten', -7.70234500, 110.59876500, '(0272) 321890', 'Setiap Hari 06:00-18:00'),
('Komunitas Peduli Sesama Klaten', 'donation', 'Jl. Nusantara No.12, Klaten Selatan', 'Klaten', -7.72345600, 110.59654300, '0817-6543-2109', 'Sabtu 08:00-12:00'),
('LAZIS NU Klaten', 'donation', 'Jl. KH Wahid Hasyim No.10, Klaten Tengah', 'Klaten', -7.70789000, 110.60098700, '(0272) 325901', 'Senin-Jumat 08:00-15:00'),
('Rumah Berbagi Prambanan', 'donation', 'Jl. Candi Prambanan No.3, Prambanan', 'Klaten', -7.75123400, 110.49234500, '0819-5432-1098', 'Sabtu-Minggu 07:00-11:00');

-- ============================================
-- DATA WARUNG / RESTORAN
-- ============================================
INSERT INTO places (name, category, address, city, latitude, longitude, phone, opening_hours) VALUES

-- === JOGJA - WARUNG / RESTO ===
('Gudeg Yu Djum', 'warung', 'Jl. Wijilan No.167, Panembahan, Kraton', 'Yogyakarta', -7.80987600, 110.36543200, '(0274) 374567', 'Senin-Minggu 06:00-22:00'),
('Warung Sate Pak Budi', 'warung', 'Jl. Kaliurang KM 8, Ngaglik, Sleman', 'Yogyakarta', -7.72345600, 110.39234500, '0812-3456-7890', 'Senin-Minggu 10:00-21:00'),
('Bale Raos', 'warung', 'Jl. Magangan Kulon No.1, Kraton', 'Yogyakarta', -7.81234500, 110.36234500, '(0274) 374567', 'Selasa-Minggu 11:00-21:00'),
('Restoran Prambanan', 'warung', 'Jl. Prambanan-Piyungan No.7, Piyungan', 'Yogyakarta', -7.75543200, 110.49876500, '(0274) 496321', 'Setiap Hari 09:00-21:00'),
('Warung Makan Bu Ageng', 'warung', 'Jl. Prawirotaman No.18, Brontokusuman', 'Yogyakarta', -7.81654300, 110.36987600, '(0274) 377890', 'Senin-Sabtu 09:00-20:00'),
('Soto Ayam Pak Marto', 'warung', 'Jl. Magelang KM 5, Sinduadi, Mlati', 'Yogyakarta', -7.74876500, 110.35678900, '0813-4567-8901', 'Senin-Minggu 06:30-14:00'),
('Warung Pecel Mbak Sri', 'warung', 'Jl. Godean KM 3, Sidoarum, Godean', 'Yogyakarta', -7.78765400, 110.32345600, '0814-5678-9012', 'Senin-Sabtu 06:00-13:00'),
('Angkringan Lik Man', 'warung', 'Jl. Wongsodirjan No.1, Gedongtengen', 'Yogyakarta', -7.79234500, 110.35987600, NULL, 'Setiap Hari 17:00-02:00'),
('Bakmi Jawa Pak Pele', 'warung', 'Jl. Malioboro No.88, Sosromenduran', 'Yogyakarta', -7.79012300, 110.36432100, '0815-6789-0123', 'Senin-Minggu 17:00-23:00'),
('Warung Kopi Blandongan', 'warung', 'Jl. Affandi No.10, Mrican, Caturtunggal', 'Yogyakarta', -7.77456700, 110.38654300, '0816-7890-1234', 'Senin-Minggu 08:00-23:00'),
('Nasi Goreng Pak Karno', 'warung', 'Jl. Seturan Raya No.9, Caturtunggal', 'Yogyakarta', -7.76123400, 110.39765400, '0817-8901-2345', 'Senin-Minggu 17:00-01:00'),
('Gudeg Pawon', 'warung', 'Jl. Janturan No.36-38, Warungboto', 'Yogyakarta', -7.80876500, 110.37654300, NULL, 'Setiap Hari 00:00-05:00'),
('Warung Bu Lies', 'warung', 'Jl. Palagan Tentara Pelajar KM 7, Ngaglik', 'Yogyakarta', -7.72678900, 110.37987600, '(0274) 868432', 'Senin-Sabtu 08:00-20:00'),
('Warung Sego Pecel Mbok Yem', 'warung', 'Jl. Bantul No.12, Dukuh, Sewon', 'Yogyakarta', -7.84234500, 110.33765400, '0818-9012-3456', 'Senin-Sabtu 06:00-13:00'),
('Kedai Kopi Kolega', 'warung', 'Jl. Selokan Mataram No.44, Sinduadi', 'Yogyakarta', -7.76345600, 110.36987600, '0819-0123-4567', 'Senin-Minggu 09:00-22:00'),

-- === KLATEN - WARUNG / RESTO ===
('Warung Soto Klaten Pak Jono', 'warung', 'Jl. Pemuda No.15, Klaten Tengah', 'Klaten', -7.70543200, 110.59543200, '0812-0234-5678', 'Senin-Minggu 06:00-14:00'),
('Nasi Gandul Bu Ning', 'warung', 'Jl. Diponegoro No.8, Klaten Tengah', 'Klaten', -7.70432100, 110.60234500, '0813-1345-6789', 'Senin-Sabtu 07:00-14:00'),
('Warung Pecel Klaten', 'warung', 'Jl. dr. Wahidin No.4, Klaten Tengah', 'Klaten', -7.70234500, 110.60012300, '0814-2456-7890', 'Senin-Sabtu 06:30-13:00'),
('Gudeg Klaten Bu Rini', 'warung', 'Jl. Merbabu No.8, Klaten Tengah', 'Klaten', -7.70876500, 110.59876500, '0815-3567-8901', 'Senin-Minggu 06:00-15:00'),
('Restoran Prambanan Sari', 'warung', 'Jl. Solo-Yogya KM 17, Prambanan', 'Klaten', -7.75345600, 110.49012300, '(0274) 496432', 'Setiap Hari 08:00-21:00'),
('Warung Bakso Pak Mul', 'warung', 'Jl. Raya Delanggu No.5, Delanggu', 'Klaten', -7.63234500, 110.65678900, '0816-4678-9012', 'Senin-Minggu 09:00-20:00'),
('Angkringan Ceper', 'warung', 'Jl. Raya Ceper No.7, Ceper', 'Klaten', -7.68987600, 110.62123400, NULL, 'Setiap Hari 16:00-23:00'),
('Warung Makan Sederhana Klaten', 'warung', 'Jl. Kopral Sayom No.3, Klaten Selatan', 'Klaten', -7.72123400, 110.59432100, '0817-5789-0123', 'Senin-Sabtu 07:00-20:00'),
('Sate Kambing Pak Harto Klaten', 'warung', 'Jl. Pemuda No.44, Klaten Tengah', 'Klaten', -7.70654300, 110.59654300, '0818-6890-1234', 'Senin-Minggu 10:00-21:00'),
('Warung Kopi Prambanan', 'warung', 'Jl. Candi Sewu No.2, Prambanan', 'Klaten', -7.75234500, 110.49456700, '0819-7901-2345', 'Senin-Minggu 07:00-22:00');

-- ============================================
-- INDEX UNTUK QUERY CEPAT (NEARBY SEARCH)
-- ============================================
CREATE INDEX idx_places_category ON places(category);
CREATE INDEX idx_places_city ON places(city);
CREATE INDEX idx_places_latlon ON places(latitude, longitude);
CREATE INDEX idx_places_active ON places(is_active);