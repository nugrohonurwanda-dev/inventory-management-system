# Inventory Management System

Aplikasi manajemen inventaris barang dengan backend **Express.js + MySQL** dan frontend **Flutter**. Setiap pengguna memiliki daftar produk dan kategori masing-masing, lengkap dengan fitur akun (registrasi, login, ganti foto profil, ganti password).

## Fitur

**Autentikasi**

- Registrasi dan login dengan username & password
- Sesi pengguna disimpan secara lokal di perangkat (`shared_preferences`)

**Produk**

- Tambah, lihat, ubah, dan hapus produk
- Setiap produk memiliki nama, jumlah stok (`qty`), kategori, dan URL gambar opsional
- Pencarian produk dari halaman menu utama
- Produk yang ditampilkan hanya milik pengguna yang sedang login

**Kategori**

- Tambah, lihat, ubah, dan hapus kategori
- Validasi nama kategori duplikat

**Profil**

- Ubah foto profil (upload gambar dari galeri/kamera)
- Ubah password

## Tech Stack

**Backend**

- [Express.js](https://expressjs.com/) — REST API framework
- [Sequelize](https://sequelize.org/) + `sequelize-cli` — ORM dan migration tool
- MySQL — database (lewat driver `mysql2`)
- [Multer](https://github.com/expressjs/multer) — upload file foto profil
- CORS

**Frontend**

- [Flutter](https://flutter.dev/) (Dart SDK `>=3.4.3 <4.0.0`)
- [Dio](https://pub.dev/packages/dio) — HTTP client
- [Provider](https://pub.dev/packages/provider) — state management
- [Shared Preferences](https://pub.dev/packages/shared_preferences) — penyimpanan sesi lokal
- [Image Picker](https://pub.dev/packages/image_picker) — pengambilan gambar untuk foto profil

Frontend dikonfigurasi sebagai proyek Flutter standar sehingga dapat dijalankan di Android, iOS, Web, Linux, macOS, dan Windows, meski pengembangan utamanya difokuskan untuk Android.

## Struktur Proyek

```
inventory-management-system/
├── backend/
│   ├── app.js                  # Entry point Express
│   ├── routes.js                # Definisi seluruh endpoint
│   ├── config/
│   │   └── config.json          # Kredensial & dialect database (Sequelize)
│   ├── controllers/
│   │   ├── userController.js
│   │   ├── categoryController.js
│   │   └── productController.js
│   ├── middleware/
│   │   └── upload.js            # Konfigurasi Multer untuk upload foto
│   ├── migrations/              # Migration Sequelize (Users, Categories, Products)
│   ├── models/                  # Model Sequelize + relasi
│   ├── seeders/                 # Data dummy untuk development
│   └── public/images/           # Lokasi penyimpanan foto profil yang diupload
│
└── frontend/
    └── flutter_application_3/
        ├── lib/
        │   ├── main.dart                 # Entry point & routing
        │   ├── login_page.dart
        │   ├── register_page.dart
        │   ├── main_menu_page.dart        # Menu utama + search
        │   ├── product_page.dart
        │   ├── category_page.dart
        │   ├── profil_page.dart
        │   ├── config/
        │   │   └── api_config.dart        # Base URL backend (WAJIB disesuaikan)
        │   ├── models/                    # Model data (Product, Category)
        │   └── providers/                 # State management (Auth, Product, Category)
        └── pubspec.yaml
```

## Skema Database

Tiga tabel utama dengan relasi sebagai berikut:

- **User** — `username`, `password`, `image`
- **Category** — `name`
- **Product** — `name`, `qty`, `categoryId`, `url`, `createdBy`, `updatedBy`

Relasi: satu `User` dapat membuat banyak `Product` (`createdBy`), satu `Category` dapat memiliki banyak `Product` (`categoryId`). Penghapusan `User` atau `Category` akan ikut menghapus `Product` terkait (`CASCADE`).

## Persiapan

Pastikan sudah terinstal:

- [Node.js](https://nodejs.org/) (disarankan versi LTS terbaru)
- [MySQL](https://www.mysql.com/) yang sedang berjalan secara lokal
- [Flutter SDK](https://docs.flutter.dev/get-started/install) beserta toolchain platform target (Android Studio untuk Android, Xcode untuk iOS/macOS, dsb.)

## Menjalankan Backend

1. Masuk ke folder backend dan install dependency:

   ```bash
   cd backend
   npm install
   ```

2. Buat database MySQL kosong, lalu sesuaikan kredensial di `backend/config/config.json` jika berbeda dari default:

   ```json
   {
     "development": {
       "username": "root",
       "password": "root",
       "database": "management_inventory_system",
       "host": "127.0.0.1",
       "dialect": "mysql"
     }
   }
   ```

3. Jalankan migration untuk membuat tabel:

   ```bash
   npm run db-migrate
   ```

4. (Opsional) Isi database dengan data dummy untuk testing:

   ```bash
   npm run db-seed
   ```

5. Jalankan server:

   ```bash
   npm start
   ```

   Atau gunakan mode development dengan auto-reload (nodemon):

   ```bash
   npm run dev
   ```

   Server berjalan di `http://localhost:3000`.

## Menjalankan Frontend

1. Masuk ke folder frontend dan install dependency:

   ```bash
   cd frontend/flutter_application_3
   flutter pub get
   ```

2. Sesuaikan `baseUrl` di `lib/config/api_config.dart` agar frontend dapat mengakses backend. Nilai yang tepat tergantung di mana aplikasi dijalankan:

   | Menjalankan di...                     | Base URL                       |
   | ------------------------------------- | ------------------------------ |
   | Android Emulator (AVD)                | `http://10.0.2.2:3000`         |
   | Genymotion                            | `http://10.0.3.2:3000`         |
   | iOS Simulator                         | `http://localhost:3000`        |
   | Device fisik (jaringan LAN yang sama) | `http://<IP-laptop-kamu>:3000` |

3. Jalankan aplikasi:

   ```bash
   flutter run
   ```

   Pastikan backend (langkah sebelumnya) sudah berjalan terlebih dahulu, dan perangkat/emulator berada di jaringan yang sama dengan backend jika menggunakan device fisik.

## Dokumentasi API

Base URL: `http://localhost:3000`

### Autentikasi & User

| Method | Endpoint               | Deskripsi                                     |
| ------ | ---------------------- | --------------------------------------------- |
| POST   | `/register`            | Registrasi user baru                          |
| POST   | `/login`               | Login user                                    |
| GET    | `/users`               | Ambil seluruh data user                       |
| PATCH  | `/update-image/:id`    | Update foto profil (form-data, field `image`) |
| PATCH  | `/update-password/:id` | Update password user                          |

### Kategori

| Method | Endpoint          | Deskripsi              |
| ------ | ----------------- | ---------------------- |
| GET    | `/categories`     | Ambil seluruh kategori |
| POST   | `/categories`     | Buat kategori baru     |
| GET    | `/categories/:id` | Ambil detail kategori  |
| PATCH  | `/categories/:id` | Update kategori        |
| DELETE | `/categories/:id` | Hapus kategori         |

### Produk

| Method | Endpoint               | Deskripsi                                |
| ------ | ---------------------- | ---------------------------------------- |
| GET    | `/products/:userid`    | Ambil seluruh produk milik user tertentu |
| GET    | `/products/detail/:id` | Ambil detail satu produk                 |
| POST   | `/products/:userid`    | Buat produk baru untuk user tertentu     |
| PATCH  | `/products/:id`        | Update produk (termasuk `qty`)           |
| DELETE | `/products/:id`        | Hapus produk                             |

## Catatan & Keterbatasan

Proyek ini dibuat sebagai bahan belajar fullstack (Express + Flutter), sehingga ada beberapa hal yang sengaja disederhanakan dan perlu diperhatikan sebelum dipakai di luar konteks belajar/development:

- **Password disimpan dalam bentuk plain text**, tanpa hashing (bcrypt, dsb). Tidak disarankan dipakai dengan data pengguna nyata tanpa menambahkan hashing terlebih dahulu.
- **Tidak ada token sesi (JWT) atau middleware otorisasi.** Identitas user di sisi frontend hanya disimpan via `shared_preferences`, dan endpoint backend tidak memverifikasi ulang siapa yang mengirim request.
- **Kredensial database tersimpan langsung di `config/config.json`** (bukan via environment variable/`.env`), jadi pastikan tidak meng-commit kredensial produksi ke repository publik.
- Field `url` pada produk menampilkan gambar dari tautan eksternal (`Image.network`), bukan upload file gambar. Upload file hanya tersedia untuk foto profil.

## Lisensi

Proyek ini menggunakan [MIT License](LICENSE).
