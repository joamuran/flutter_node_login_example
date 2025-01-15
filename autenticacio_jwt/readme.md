
Anem a avançar una miqueta més en l'exemple d'autenticació i a incorporar connexions segures i tokens, així com a estructurar una miqueta millor el projecte des del costat del servidor.

Concretament, anem a veure:

1. Com generar certificats SSL/TSL, necessaris per configurar HTTPS en el servidor.
2. Com configurar JWT (JSON Web Tokens), un mecanisme modern per autenticar peticions a un servidor. Veurem com generar els tokens i validar-los en rutes protegides. Per a això, s'implementarà un middleware que verigique tokens JWT i restringisca l'accés a determinades rutes.
3. Estructurarem el projecte seguint un patró MVC, generant carpetes per a controladors, models, rutes i configuracions.
4. Configurarem el client per tal de realitzar la connexió a través d'HTTPS i gestionar els tokens.


## Part 1. HTTPS. Generació de Claus SSL/TLS i Configuració.

Per poder comunicar-nos de forma segura amb el servidor, necessitem un protocol segur. Amb les connexions HTTP, les dades viatgen *en cru* per Internet, i qualsevol usuari que analitzara el tràfic podria obtenir credencials d'accés o dades confidencials.

Per a això s'utilitza el protocol HTTPS, que s'encarrega d'encriptar la informació entre client i servidor. Aquest protocol utilitza un sistema de claus criptogràfiques per assegurar que la informació viatja de manera encriptada i només pot ser desxifrada pel destinatari previst. Per aconseguir-ho, HTTPS es basa en protocols de seguretat com **SSL (Secure Sockets Layer)** o el més modern **TLS (Transport Layer Security)**.

> [!NOTE]
> ***Sobre SSL i TSL***
>
> Els protocols SSL i TSL són protocols de xarxa que treballen en el nivell de *Transport*, i garanteixen tres dels pilars fonamentals de la seguretat de les dades:
>
> 1. **Confidencialitat:** Les dades es transmeten encriptades, de manera que, encara que algú intercepte el tràfic, no podrà llegir-les.
>2. **Integritat:** Es verifica que les dades no hagen estat modificades durant la transmissió.
>3. **Autenticitat:** Mitjançant certificats digitals, el client pot confirmar que està parlant amb el servidor legítim.
>
> Quan un client es connecta al servidor via HTTPS, es realitza un procés conegut com **handshake** (encaixada de mans), on el servidor presenta el seu certificat digital. Aquest certificat inclou una clau pública que s'utilitza per establir una connexió segura, garantint la protecció de les dades transmeses.
> 

Així doncs, el primer pas, consisteix en l'obtenció d'aquets certificats. 

> [!WARNING]
>
> Els certificats amb què treballarem seran certificats autofirmats, que generarem per a Express, i seran útils per a entorns de desenvolupament, però no per a entorns de producció.
>
> En entorns de producció necessitariem obtenir els certificats d'una autoritat de certificació (CA) reconeguda, que proporcione confiança i garantisca l'autenticitat. Quan un usuari visita un lloc web amb un certificat autofirmat, veurem un avís de seguretat, indicant que la connexió no és segura, el que pot fer desconfiar a l'usuari del lloc.
>

### Generació de certificats autofirmats

Per generar els certificats farem ús d'`openssl`, una eina comuna en entorns de desenvolupament.

Per a això executem la següent ordre des de la terminal:

```bash
openssl req -nodes -new -x509 -keyout server.key -out server.cert -days 365
```

On:

* **`req`**: Indica que volem utilitzar l'eina de creació de sol·licituds de certificats X.509 d'OpenSSL.
* **`-nodes`**: Significa *no DES* (Data Encryption Standard). Aquest paràmetre evita que la clau privada generada estiga encriptada amb una contrasenya. Això és útil en entorns de desenvolupament on no volem introduir una contrasenya cada vegada que carreguem el certificat.
* **`-new`**: Indica que volem generar una nova sol·licitud de certificat (CSR) i una clau privada associada.
* **`-x509`**: Indica que volem generar un certificat autofirmat.
* **`-keyout server.key`**: Indica el fitxer on es guardarà la clau privada generada (`server.key`).
* **`-out server.cert`**: Indica el fitxer on es guardarà el certificat autofirmat (`server.cert`).
* **`-days 365`**: Defineix el període de validesa del certificat, en dies.

Quan llancem l'ordre ens demanaran algunes dades, com el país, la ciutat o la població. Podem omplir-les o simplement prémer Enter per deixar-les en blanc.

Això ens generarà doncs dos fitxers: `server.key` i `server.cert`, amb la clau privada i el certificat, respectivament. Aquests fitxers els guardarem en una carpeta `certs` a l'arrel del projecte (que hem creat prèviament amb `npm init`):


```plaintext
autenticacio_jwt/
├── certs
│   ├── server.cert
│   └── server.key
└── package.json
```

### Creació del servidor HTTPS

Una vegada generats els certificats, anem a configurar un servidor HTTPS bàsic utilitzant els certificats generats. Per a això, i a l'arrel del projecte:

1. Instal·lem la dependència d'Express:

   ```bash
   npm install express
   ```

2. Creem el fitxer principal `app.js` amb el següent codi (reviseu els comentaris per anar entenent el codi!):

```javascript
import express from 'express';
import https from 'https';
import fs from 'fs';

// Carregar els certificats i crea un JSON anomenat credentials
const privateKey = fs.readFileSync('./certs/server.key', 'utf8');
const certificate = fs.readFileSync('./certs/server.cert', 'utf8');
const credentials = { key: privateKey, cert: certificate };

// Definim app com a una aplicació Express
const app = express();

// Incorporem el middleware per gestionar sol·licituds JSON
app.use(express.json());

// Creem una ruta de prova
app.get('/', (req, res) => {
  res.send('Connexió segura establerta amb HTTPS!');
});

// Creem el servidor HTTPS amb les credencials i l'aplicació Express
const httpsServer = https.createServer(credentials, app);

// Escoltar al port 3000
httpsServer.listen(3000, () => {
  console.log('Servidor HTTPS en execució a https://localhost:3000');
});
```

I modifiquem el fitxer `package.json` per a que accepte mòduls ES6 i incorpore l'script `start`.

 ```json
{
  "name": "autenticacio_jwt",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "type": "module",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "nodejs app.js"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.21.2"
  }
}
```

Amb això, si llancem el servidor amb `node app.js` o `npm start`, podrem obrir el navegador i visitar [https://localhost:3000](https://localhost:3000). Segurament el navegador ens mostre que es tracta d'una connexió no confiable, ja que estem treballant amb un certificat no emès per cap CA:

![](img/https_no_segur.png)

Si ens bloqueja la pàgina, mostrem la configuració avançada i indiquem que sí que confiem en el lloc. 

Una vegada dins, podem veure el missatge *Connexió segura establerta amb HTTPS!*.

> [!NOTE]
>
> Com veiem al codi hem crear el servidor HTTPS amb `const httpsServer = https.createServer(credentials, app);`, i és aquest amb qui fem el `https.listen` posteriorment.
>
> Alternativament, també podríem seguir fent un `app.listen`, per atendre peticions HTTP per altre port.


## Part 2. JWT per a l'autenticació

Una vegada configurat HTTPS, anem a configurar JWT per al servidor Express. Els pasos principals en aquesta part seran:

1. Creació del token JWT una vegada autenticat
2. Incorporació d'un middleware per validar tokens JWT
3. Protecció de rutes amb autenticació basada en tokens.

> [!NOTE]
> **Però... què és JWT i què són els tokens?**
>
> JWT (JSON Web Token) és un estàndard per a l'intercanvi de dades segures entre dues parts (normalment, un client i un servidor). Els tokens són com *passaports digitals* que permeten als usuaris accedir a recursos protegits sense haver de tornar a autenticar-se a cada sol·licitud.
> 
>  Els tokens consten de tres parts: una **capçalera (header)** amb el tipus de token i l'algorisme utilitzat per a la signatura, la **càrrega (payload)** amb les dades que el servidor vol compartir, com l'id d'usuari, els rols i l'expiració del token, i una **signatura** per verificar la integritat del token (que no ha estat alterat pel camí).
>
> Quan el client es connecta al servidor i es valida correctament, el servidor genera un token JWT i l'envia al client. El client ha d'incloure aquest token en l'encapçalament de cada petició a rutes protegides, fent ús del paràmetre `Authorization`. El servidor verifica la signatura del token per garantir que és vàlid i decideix si l'usuari té accés al recurs. 
> 

* **Pas 1. Instal·lació de dependències necessàries**

En primer lloc, afegim les següents llibreries `jsonwebtoken` (per generar i validar els tokens JWT) i `bcryptjs` (per encriptar i comparar contrasenyes de manera segura):

```bash
npm install jsonwebtoken bcryptjs
```

* **Pas 2. Estructura del projecte**

Com que ja anem a treballar amb diverses rutes, anem a estructurar el nostre projecte seguint un patró MVC. L'estructura del projecte serà (hem obviat la carpeta node_modules i el fitxer package-lock.json):

```plaintext
autenticacio_jwt
├── app.js
├── certs
├── controllers
├── middlewares
├── models
├── package.json
└── routes
```

* **Pas 3. Creació del Model d'Usuari**

Creem el fitxer `models/users.js`, amb una llista d'usuaris simulada amb funcions per autenticar i gestionar usuaris. En casos reals, aquesta llista deuria ser una base de dades.

El codi d'aquests fitxer és el següent (presteu atenció de nou als comentaris!):

```javascript
import bcrypt from 'bcryptjs';

// Llista d'usuaris, inicialment buida
const users = [];

// Funció asíncrona (async) per registrar un usuari.
// Amb export fem que la funció siga visible des de fora de l'script
export const registerUser = async (username, password) => {
    // Com que la funció hash és asíncrona i tarda un temps, ens esperem que acabe
    const hashedPassword = await bcrypt.hash(password, 10); // Encriptar contrasenya
    // Afegim l'usuari, amb el password encriptat
    users.push({ username, password: hashedPassword });
    // I el retornem
    return { username };
};

// Funció asíncrona per validar un usuari
export const authenticateUser = async (username, password) => {
    // Busquem l'usuari een la llista
    const user = users.find(u => u.username === username);
    if (!user) return null; // Si l'usuari no existeix retornem nl

    // Si l'usuari existeix, comparem el password proporcionat amb el guardat, 
    // tot de manera encriptada
    const isPasswordValid = await bcrypt.compare(password, user.password);
    // Si el password és vàlid, retornem l'usuari, i si no, retornem null
    return isPasswordValid ? user : null;
};

```

Obsereveu les funcions `registerUser` i `authenticateUser`, que es defineixen:

```js
export const nom_funcio = async (paràmetres) => {
    ...await ...
};
```

En primer lloc, observeu que podem definir la funció `nom_fucio` com una constant, i sense utilitzar `function`.

Després, cal dir que es tracta d'una funció **asíncrona** (`async`). Amb **`async`**, indiquem aquesta funció pot treballar amb operacions que prenen un temps a completar-se sense bloquejar el programa (per exemple, les operacions d'encriptar les contrassenyes).

Quan dins una funció volem esperar a que finalitze una operació asíncrona, fem ús d'`await`. Com veiem, és exactament el mateix mecanisme que amb Flutter, i l'`await` només es pot utilitzar dins de funcions `async`.

El mecanisme que s'utilitza en aquest cas amb Javascript són els objectes Promesa (*Promise*), que és el resultat que retornen les funcions asíncrones, i que es resolen al resultat més tard, de la mateixa manera que fan els `Future` en Flutter.


* **Pas 4. Creació del Controlador**

Ara afegim el controlador al fitxer `controllers/authController.js`, que implementa la lògica d'autenticació.

Abans d'això, anem a instal·lar la llibreria de nodejs `dotenv`, que ens ajudarà a treballar amb variables d'entorn necessàries:

```bash
npm install dotenv
```

El codi complet del controlador quedarà:

```javascript
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
```

La **`SECRET_KEY`** és una clau que s'utilitza per signar i verificar la integritat dels tokens JWT, de manera que garantim que el tiken no s'haja alterat després de ser generat.

Com veiem, per signar el token fem ús de la funció `jwt.sign`, proporcionant com a *Payload* el camp nom d'usuari:

```javascript
const token = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
```

Aquest token generat serà únic i només podrà ser validat amb la mateixa clau secreta.

Quan el client envia el token en una sol·licitud (normalment en l'encapçalament `Authorization`), el servidor utilitza la mateixa **`SECRET_KEY`** per verificar que el token és vàlid i no ha estat modificat. Si el token no es correspon amb la signatura esperada (calculada amb la **`SECRET_KEY`**), es considera invàlid.

Per a això, fem ús de la funció `jwt.verify`:

```javascript
const payload = jwt.verify(token, SECRET_KEY);
```

De manera que si el **token** no es pot verificar correctament amb la **`SECRET_KEY`**, es llança un error, indicant que el token és invàlid o manipulat.

Aquesta clau secreta és de gran importància, ja que si algú es fa amb ella, podria crear tokens falsos, o manipular tokens legítims. Per això, la clau secreta **ha d'estar protegida i no ha d'incloure's al codi font**, guardant-se generalment en variables d'entorn (`.env`).

Per això hem instal·lat la llibreria `dotenv`, que ens permet gestionar **variables d'entorn** d'una manera senzilla i segura. Aquestes variables s'emmagatzemen en un fitxer separat (`.env`) i es carreguen al programa perquè siguen accessibles com a variables globals.

Aleshores, crearem un fitxer, a l'arrel del projecte anomenat `.env`, al qual guardarem les variables d'entorn. El seu contingut serà el següent:

```javascript
SECRET_KEY="clauSuperSecretaISegura"
```

Aquesta mecanisme ens serveix per emmagatzemar dades sensibles al servidor, com aquestes claus secretes, però també credencials d'accés a bases de dades, URLs, etc. de manera que no estiguen al propi codi de l'aplicació.

Com viem, per carregar les variables d'entorn, només cal carregar `dotenv` al començament:
   
```javascript
import dotenv from 'dotenv';

dotenv.config();
```

I amb això carregarem les variables definides al fitxer `.env` a `process.env`, de manera que tenim la clau accessible a `process.env.SECRET_KEY`.

* **Pas 5. Middleware per Validar Tokens**

Ara crearem una nova funció (Middleware) per protegir les rutes. Aquesta es guardarà en `middlewares/authMiddleware.js`:

```javascript
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
```

### **6. Rutes d'Autenticació**

A `routes/authRoutes.js`, configurem les rutes per al registre i login.

```javascript
import express from 'express';
import { register, login } from '../controllers/authController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

// Creem el router
const router = express.Router();

// Configurem les rutes d'autenticació
router.post('/register', register);
router.post('/login', login);

// Creem unaruta protegida d'exemple
// Abans de passar al middleware que gestiona aqueta petició (el res.send), 
// ha de passar pel middleware autMiddleware o obtindre el token d'autenticació.
router.get('/protected', authenticateToken, (req, res) => {
  res.send({ message: `Benvingut, ${req.user.username}!` });
});

export default router;
```

---

### **7. Configuració del Servidor**

Finalment, a `app.js`, integrem tot:

```javascript
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
```

