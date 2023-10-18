import 'package:andrestable/page/forgotPwPages/page2.dart';
import 'package:flutter/material.dart';

class ForgotPwPage extends StatelessWidget {
  String username = '';
  String email = '';
  ForgotPwPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié ?'),
      ),
      body: Center(
        child: Form(
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) => username = value,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
              ),
              TextFormField(
                onChanged: (value) => email = value,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                decoration: InputDecoration(labelText: 'Adresse email'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPwPage2(),
                    ),
                  );
                },
                child: const Text('Suite'),
              ),
            ],
          ),
        )
        ),
      );
  }
}
