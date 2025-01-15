import express from 'express';
import { register, login } from '../controllers/authController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

// Creem el router
const router = express.Router();

// Configurem les rutes d'autenticació
router.post('/register', register);
router.post('/login', login);

// Creem una ruta protegida d'exemple
router.get('/protected', authenticateToken, (req, res) => {
  res.send({ message: `Benvingut, ${req.user.username}!` });
});

export default router;