import 'package:flutter/material.dart';

class AccountFormModel {
  String name = '';
  String firstname = '';
  String phone = '';
  String email = '';
  String password = '';
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
                  hintText: 'Entrez votre nom',
                  labelText: 'Nom',
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'Entrez votre nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _accountForm.name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Entrez votre prénom',
                  labelText: 'Prénom',
                ),
                onSaved: (String? value) {

                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: 'Entrez votre téléphone',
                  labelText: 'Téléphone',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.numbers),
                  hintText: 'Entrez votre email',
                  labelText: 'Mail',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.password),
                  hintText: 'Entrez votre mot de passe',
                  labelText: 'Mot de passe',
                ),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
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
