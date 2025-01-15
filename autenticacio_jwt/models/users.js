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

