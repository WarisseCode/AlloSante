import express from 'express';
import cors from 'cors';

// Routes
import authRoutes from './modules/auth/auth.routes.js';
import doctorRoutes from './modules/doctors/doctors.routes.js';
import appointmentRoutes from './modules/appointments/appointments.routes.js';
import medicalRecordRoutes from './modules/medical-records/medical-records.routes.js';
import usersRoutes from './modules/users/users.routes.js';

// Middlewares
import { errorMiddleware, notFoundMiddleware } from './middlewares/error.middleware.js';

const app = express();

// Global middlewares
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/medical-record', medicalRecordRoutes);
app.use('/api/users', usersRoutes);

// Error handling
app.use(notFoundMiddleware);
app.use(errorMiddleware);

export default app;
