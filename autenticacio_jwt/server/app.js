import express from 'express';
import https from 'https';
import fs from 'fs';
import authRoutes from './routes/authRoutes.js';

// Carregar els certificats i crea un JSON anomenat credentials
const privateKey = fs.readFileSync('./certs/server.key', 'utf8');
const certificate = fs.readFileSync('./certs/server.cert', 'utf8');
const credentials = { key: privateKey, cert: certificate };

// Definim app com a una aplicació Express
const app = express();

// Incorporem el middleware per gestionar sol·licituds JSON
app.use(express.json());

/*
// Middleware per veure totes les peticions que rebem
app.use("*", (req, res, next) => {
  console.log("Rebuda");
  console.log(req.body);
  next();
});
*/


// Configurem les rutes d'autenticació
app.use('/auth', authRoutes);

// Creem el servidor HTTPS
const httpsServer = https.createServer(credentials, app);
httpsServer.listen(3000, () => {
  console.log('Servidor HTTPS amb JWT en execució a https://localhost:3000');
});