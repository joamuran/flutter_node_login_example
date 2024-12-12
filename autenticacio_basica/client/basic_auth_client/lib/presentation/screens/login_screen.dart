import 'package:flutter/material.dart';
import 'package:basic_auth_client/domain/repository/auth_repository.dart';
import 'principal.dart';

/// Pantalla per al formulari de login
/// La definim com un giny sense estat que contindrà el formulari
class LoginScreen extends StatelessWidget {
  final AuthRepository repository;

  const LoginScreen({required this.repository, super.key});

  // Aquest giny ens construeix l'Scaffold, que té com a fill al body el formulari en sí
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Tindrà com a fill el widget per al login
        child: LoginForm(repository: repository),
      ),
    );
  }
}

/// Pas 1. Creació del giny amb estat personalitzat.
/// Definim un widget per al login, que serà un giny personalitzat amb estat.
/// Aquest estat construirà un giny de tiput Form.
/// Els widgets de tipus Form són necessaris per agrupar diferents widgets amb els quals interactuen els usuaris.
/// A més, possibiliten les validacions en el formulari.
class LoginForm extends StatefulWidget {
  final AuthRepository repository;

  // Constructor (necessita el repositori)
  const LoginForm({required this.repository, super.key});

  /// /// Estat per a la pantalla de Login
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  // Afegim a l'estat una clau global (GlobalKey)
  // La diferència amb una key és que aquesta permet l'accés des de qualsevol lloc de l'aplciació
  final _formKey = GlobalKey<FormState>();

  // Definim dos controladors per als camps de text.
  // Aquests controladors ens permetran accedir als camps de text, modificar el seu valor,
  // i realitzar les validacions.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Flag booleà per indicar que s'està fent la validació
  bool _isLoading = false;

  // Funció privada a la classe per realitzar el login
  Future<void> _login() async {
    // Pas 3. Processament del formulari.
    // Aci fem les validacions, i si és corregte, el processem.

    if (!_formKey.currentState!.validate()) {
      // Si el formulari no és vàlid, no continua
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final resposta = await widget.repository
          .login(_usernameController.text, _passwordController.text);

      if (resposta) {
        // Si l'autenticació té èxit, naveguem a una altra pantalla
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPrincipal(
              user: _usernameController.text,
            ),
          ),
        );
      } else {
        _showErrorDialog('Credencials incorrectes');
      }
    } catch (e) {
      _showErrorDialog('Error d’autenticació: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pas 2. Afegim els ginys al formulari
    // Per al cas dels camps de text, disposem de TextFormField, que ens permet accedir
    // ja al contingut i fer les validacions. Per a altres tipus de ginys, hauriem de fer
    // ús del ginys FormField per envoltar els ginys de formulari.

    return Form(
      // Afegim com a clau del formulari la clau _formKey que hem generat
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _usernameController, // Controlador
            decoration:
                const InputDecoration(labelText: 'Usuari'), // Aspecte del giny
            validator: (value) {
              // Validador: Es defineix com una funció anònima, que
              // rep el valor del camp de text. Comprovem que s'haja introduit algun valor.
              if (value == null || value.isEmpty) {
                // Retornem un missatge d'error
                return 'El camp Usuari és obligatori';
              }
              // Si retornem null, es dona per validat
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Contrasenya'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El camp Contrasenya és obligatori';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _isLoading // Si :isLoading és cert, es mostra un indicador de progrés mentre es fa l'autenticació
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  // En cas contrari, es mostra el botó
                  onPressed: _login,
                  child: const Text('Accedir'),
                ),
        ],
      ),
    );
  }
}
