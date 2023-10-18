import 'package:andrestable/main.dart';
import 'package:andrestable/page/forgotPwPages/page1.dart';
import 'package:andrestable/page/homePage.dart';
import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';

class LoginFormModel {
  String username = '';
  String password = '';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginForm = LoginFormModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                // ... (Your username TextFormField)
              ),
              TextFormField(
                // ... (Your password TextFormField)
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  // ... (Your login logic)
                },
                child: const Text('Se connecter'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPwPage(),
                    ),
                  );
                },
                child: const Text('Mot de passe oublié ?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
