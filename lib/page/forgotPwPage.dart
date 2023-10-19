import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';

class ModifyPwModel {
  String username = '';
  String email = '';
}


class ForgotPwPage extends StatefulWidget {
  ForgotPwPage({Key? key}) : super(key: key);
  @override
  _ForgotPwPageState createState() => _ForgotPwPageState();
}

class _ForgotPwPageState extends State<ForgotPwPage> {
  final _formKey = GlobalKey<FormState>();
  final _modifyPw = ModifyPwModel();
  String newPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié ?'),
      ),
      body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                TextFormField(
                  decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom d\'utilisateur';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _modifyPw.username = value!;
                  },
                ),


                TextFormField(
                  decoration: InputDecoration(labelText: 'Adresse email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _modifyPw.email = value!;
                  },
                ),

                const SizedBox(height: 20.0),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      bool idValid = await MongoDataBase().verifyPw(
                          _modifyPw.username, _modifyPw.email, "users");

                      if (idValid) {
                        _showModifyPwDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Identifiants incorrects'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }

                    }
                  },
                  child: const Text('Suite'),
                ),

              ],
            ),
          )
      ),
    );
  }

  void _showModifyPwDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le mot de passe'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) => newPassword = value,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  bool idValid = await MongoDataBase().changePw(_modifyPw.username, _modifyPw.email, newPassword, "users");
                  setState(() {
                    if (idValid) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                    print(Text('Mot de passe modifié 1'));
                  });
                  print(Text('Mot de passe modifié'));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }
}