const multer = require("multer");
const path = require("path");

// KONFIGURASI PENYIMPANAN
const storage = multer.diskStorage({
    destination: (req, file, cb) => {

        // LOKASI FILE YANG TELAH DI UPLOAD DISIMPAN
        // BERADA FOLDER IMAGES YANG ADA DI FOLDER PUBLIC
        cb(null, 'public/images'); 
    },
    filename: (req, file, cb) => {

        // FORMAT NAMA FILE SETELAH BERHASIL DI UPLOAD = YYYY-MM-DD-HH-MM-SS-image.ext
        const currentDate = new Date();
        const year = currentDate.getFullYear();
        const month = String(currentDate.getMonth() + 1).padStart(2, '0');
        const date = String(currentDate.getDate()).padStart(2, '0');
        const hours = String(currentDate.getHours()).padStart(2, '0');
        const minutes = String(currentDate.getMinutes()).padStart(2, '0');
        const seconds = String(currentDate.getSeconds()).padStart(2, '0');
        const ext = path.extname(file.originalname);
        const uniqueSuffix = `${year}-${month}-${date}-${hours}-${minutes}-${seconds}-image${ext}`;
        cb(null, uniqueSuffix);
    }
});

// Middleware upload file
const upload = multer({
    storage: storage,

    // LIMIT FILE SIZE 5 MB
    limits: {
        fileSize: 5 * 1024 * 1024
    },
    fileFilter: (req, file, cb) => {
        // Filter hanya untuk file gambar
        if (file.mimetype.startsWith('image') && (file.mimetype.endsWith('jpeg') || file.mimetype.endsWith('jpg') || file.mimetype.endsWith('png'))) {
            cb(null, true);
        } else {
            cb(new Error('Only images in jpeg, jpg, or png format are allowed!'));
        }
    }
});

module.exports = upload;