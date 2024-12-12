// index.js
import express, { json } from 'express';
import cors from 'cors';

const app = express();
const PORT = 3000;

// Configuració de middlewares inicial
app.use(cors());  // Indiquem al servidor que accepte servidors de dominis i ports diferents (https://developer.mozilla.org/es/docs/Web/HTTP/CORS)
app.use(json());  // Per tal que l'aplicació interprete en JSON enviat pel client

// Definim un usuari fix per a validació
const USERNAME = "alumne";
const PASSWORD = "2DAM";

// Ruta de login: Fem ús de POST en lloc de GET, ja que volem que
// els paràmetres de la petició vagen en el body, no en la URL
app.post("/login", (req, res) => {

  // Exemple de *Deconstrucció*. En req.body (cos de la petició) tenim els paràmetres en JSON que
  // ens proporciona el client. En lloc de fer:
  // const username = req.body.username;
  // const password = req.body.password;
  // Amb la deconstrucció, podem reescriure estes línies com:
  const { username, password } = req.body;

  // Comprovem l'usuari i la contrassenya
  if (username === USERNAME && password === PASSWORD) {
    res.status(200).json({ success: true }); // Autenticació correcta: Tornem Status 200 (OK) i el JSON {succes:true}
  } else {  // Autenticació incorrecta. Retornem un status 401 (Unauthorized) i un JSON amb succes:false i un missatge
    res.status(401).json({ success: false, message: "Credencials incorrectes" });
  }
});

// Iniciem el servidor
app.listen(PORT, () => {
  console.log(`Servidor en funcionament al port ${PORT}`);
});
