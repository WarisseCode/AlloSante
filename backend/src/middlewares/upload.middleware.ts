import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Ensure uploads directory exists
const uploadDir = 'uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    },
});

const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
    console.log('Upload attempt:', {
        mimetype: file.mimetype,
        originalname: file.originalname,
        encoding: file.encoding
    });
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else if (file.mimetype === 'application/octet-stream' &&
        (file.originalname.endsWith('.jpg') || file.originalname.endsWith('.jpeg') || file.originalname.endsWith('.png'))) {
        console.log('Allowing octet-stream based on extension');
        cb(null, true);
    } else {
        cb(new Error('Le fichier doit être une image. Recieved type: ' + file.mimetype));
    }
};

export const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
});
