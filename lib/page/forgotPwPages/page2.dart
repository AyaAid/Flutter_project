import 'package:flutter/material.dart';

class ForgotPwPage2 extends StatelessWidget {
  String username = '';
  String email = '';
  ForgotPwPage2({Key? key}) : super(key: key);

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
                  decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // ... (Your forgot password logic)
                  },
                  child: const Text('Envoyer'),
                ),
              ],
            ),
          )
      ),
    );
  }
}
