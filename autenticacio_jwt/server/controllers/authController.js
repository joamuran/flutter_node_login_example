import jwt from 'jsonwebtoken';
import { registerUser, authenticateUser } from '../models/users.js';

// Llibreria per a les variables d'entorn
import dotenv from 'dotenv';

// Definim una clau secreta per signar els tokens
// const SECRET_KEY = 'Aquesta_no_es_una_bona_manera_de_guardar_la_clau_secreta';

// Aquesta és la forma correcta d'accedir a les claus secretes
dotenv.config();
const SECRET_KEY = process.env.SECRET_KEY;

// Registre d'usuari
export const register = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }
  const newUser = await registerUser(username, password);
  res.status(201).send(newUser);
};

// Login d'usuari
export const login = async (req, res) => {
  console.log("Rebuda petició post...");
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }

  const user = await authenticateUser(username, password);
  if (!user) {
    return res.status(401).send({ error: 'Credencials incorrectes' });
  }

  const token = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
  res.send({ token });
};