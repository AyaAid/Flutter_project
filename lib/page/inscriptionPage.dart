import 'dart:convert';
import 'dart:typed_data';

import 'package:andrestable/page/homePage.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../database/mongodb.dart';

class AccountFormModel {
  String username = '';
  String email = '';
  String password = '';
  Uint8List? image;
}

class NewAccount extends StatefulWidget {
  const NewAccount({super.key});

  @override
  _CreateAccount createState() => _CreateAccount();
}

class _CreateAccount extends State<NewAccount> {
  final _formKey = GlobalKey<FormState>();
  final _accountForm = AccountFormModel();
  String hashedpassword = '';
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxHeight: 300, maxWidth: 300);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _accountForm.image = imageBytes;
      });
    }
  }
  




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
                  labelText: 'Username',
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
                validator: (value) {
                  final emailRegex = RegExp(r"^[a-z0-9.a-z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                  if (value == null || value.isEmpty) {
                    return 'Entrez votre email';
                  } else if (!emailRegex.hasMatch(value)) {
                    return 'Entrez une adresse e-mail valide';
                  }
                    else if (value == MongoDataBase().getEmail()){
                    return 'Cette adresse mail existe déjà';
                  }


                  return null;
                },
                onSaved: (String? value) {
                  _accountForm.email = value!;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.password),
                  hintText: 'Entrez votre mot de passe',
                  labelText: 'Mot de passe',
                ),
                validator: (value) {
                  final passwordRegex = RegExp(r"^[A-Z0-9]+[a-z0-9]+[!#$%&'*+-/=?^_`{|}~]+[0-9]");

                  if (value == null || value.isEmpty) {
                    return 'Entrez votre mot de passe';
                  } else if (!passwordRegex.hasMatch(value)) {
                    return 'Entrez un mot de passe valide';
                  }

                  return null;
                },
                onSaved: (String? value) {
                  _accountForm.password = value!;
                },
              ),
              Padding(padding: EdgeInsets.all(20)),
              GestureDetector(
                onTap: _getImage,
                child: _image == null
                    ? Container(
                  width: 50,
                  height: 50,
                  color: Colors.pinkAccent,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                )
                    : Image.file(_image!),
              ),
              Padding(padding: EdgeInsets.all(20)),
              ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.all(10))
                  ),
                  onPressed: () async {
                    hashedpassword = BCrypt.hashpw(_accountForm.password, BCrypt.gensalt(),
                    );
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      var users = {
                        'Username': _accountForm.username,
                        'email': _accountForm.email,
                        'password': hashedpassword,
                        'image': _accountForm.image,
                      };
                      bool isValid = await MongoDataBase().addUserToDB(users, "users");
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'ajouter votre licorne pour le moment, réessayez plus tard'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Text("s'inscrire")),
            ],
          ),
        ),
      ),
    );
  }
}
