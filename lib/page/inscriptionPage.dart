import 'package:flutter/material.dart';

class AccountFormModel {
  String username = '';
  String email = '';
  String password = '';
  String photo = '';
}

class NewAccount extends StatefulWidget {
  const NewAccount({super.key});

  @override
  _CreateAccount createState() => _CreateAccount();
}

class _CreateAccount extends State<NewAccount> {
  final _formKey = GlobalKey<FormState>();
  final _accountForm = AccountFormModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer son compte'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Entrez votre username',
                  labelText: 'username',
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'Entrez votre username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _accountForm.username = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.numbers),
                  hintText: 'Entrez votre email',
                  labelText: 'Mail',
                ),
                onSaved: (String? value) {
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.password),
                  hintText: 'Entrez votre mot de passe',
                  labelText: 'Mot de passe',
                ),
                onSaved: (String? value) {
                },
              ),

              Padding(padding: EdgeInsets.all(20)),
              ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.all(10))
                  ),
                  onPressed: () {

                  },
                  child: Text("s'inscrire")),
            ],

          ),
        ),
      ),
    );
  }
}
