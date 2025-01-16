import 'package:basic_auth_client/domain/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class PantallaPrincipal extends StatefulWidget {
  final AuthRepository repository;

  const PantallaPrincipal({super.key, required this.repository});

  @override
  PantallaPrincipalState createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  Future<String>? future;

  Future<String> _fetchProtectedResource() async {
    try {
      final response =
          await widget.repository.getProtectedResource("/auth/protected");
      return response.body;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurs Protegit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Accés concedit!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Text(
                      'Resposta del servidor: ${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                }

                // Estat inicial: mostrar el botó
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      future = _fetchProtectedResource();
                    });
                  },
                  child: const Text('Obtenir recurs protegit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// Versió anterior 
/*import 'package:flutter/material.dart';

class PantallaPrincipal extends StatelessWidget {
  String? user;
  PantallaPrincipal({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benvingut $user')),
      body: Center(
        child: Column(
          children: [
            Text('Accés concedit!', style: TextStyle(fontSize: 24)),
            FutureBuilder(future: future, builder: builder)
          ],
        ),
      ),
    );
  }
}
*/