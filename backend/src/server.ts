import app from './app.js';
import { config } from './config/env.js';

const PORT = config.port;

app.listen(PORT, () => {
    console.log('');
    console.log('╔══════════════════════════════════════════════╗');
    console.log('║       🏥 ALLOSANTÉ BACKEND API               ║');
    console.log('╠══════════════════════════════════════════════╣');
    console.log(`║  🚀 Le serveur tourne sur le port ${PORT}              ║`);
    console.log(`║  📍 http://localhost:${PORT}                   ║`);
    console.log(`║  🔧 Environment: ${config.nodeEnv.padEnd(19)}║`);
    console.log('╚══════════════════════════════════════════════╝');
    console.log('');
    console.log('Available endpoints:');
    console.log('  POST   /api/auth/register');
    console.log('  POST   /api/auth/login');
    console.log('  POST   /api/auth/verify-otp');
    console.log('  GET    /api/doctors');
    console.log('  GET    /api/doctors/:id');
    console.log('  POST   /api/appointments');
    console.log('  GET    /api/appointments');
    console.log('  GET    /api/medical-record');
    console.log('');
});
