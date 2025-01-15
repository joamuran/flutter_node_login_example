import jwt from 'jsonwebtoken';

// Llibreria per a les variables d'entorn
import dotenv from 'dotenv';

dotenv.config();
const SECRET_KEY = process.env.SECRET_KEY;

export const authenticateToken = (req, res, next) => {
  // Busquem el camp Authorization en la capçalera
  const authHeader = req.header('Authorization');

  // obtenim el token (component 1)
  const token = authHeader && authHeader.split(' ')[1];

  // Si no hi ha token retornem error
  if (!token) {
    return res.status(401).send({ error: 'Token no proporcionat' });
  }

  // Verifiquem el token, i extraiem l'usuari
  try {
    const payload = jwt.verify(token, SECRET_KEY);
    req.user = payload;
    // Amb next, "botem" al pròxim middleware
    next();
  } catch (err) {
    res.status(403).send({ error: 'Token no vàlid' });
  }
};