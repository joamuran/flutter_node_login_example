// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:basic_auth_client/infrastructure/data_source/auth_remote_datasource.dart';
import 'package:basic_auth_client/infrastructure/repository/auth_repository_impl.dart';
import 'package:basic_auth_client/presentation/screens/login_screen.dart';

void main() {
  // Inicialització de l'API d'accés a les dades des de la xarxa
  // final authRemoteDatasource = AuthRemoteDataSource("http://10.0.2.2:3000");
  // Modificació: Ara ens connectem per HTTPS
  final authRemoteDatasource = AuthRemoteDataSource("https://10.0.2.2:3000");
  final authRepository = AuthRepositoryImpl(authRemoteDatasource);
  runApp(LoginApp(repository: authRepository));
}

class LoginApp extends StatelessWidget {
  final AuthRepositoryImpl repository;

  const LoginApp({required this.repository, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemple de login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(
        repository: repository,
      ),
    );
  }
}
