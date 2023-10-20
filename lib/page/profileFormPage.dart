import 'package:flutter/material.dart';

import '../database/mongodb.dart';

class UserProfile {
  String username;
  String fullName;
  String email;
  String phoneNumber;
  String link;
  DateTime dateOfBirth;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.link,
    required this.dateOfBirth,
  });
}


class MonProfilePage extends StatefulWidget {
  @override
  _MonProfilePageState createState() => _MonProfilePageState();
}

class _MonProfilePageState extends State<MonProfilePage> {
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    final loggedInUsername = SessionManager().getLoggedInUser();

    if (loggedInUsername != null) {
      MongoDataBase().getUserProfile(loggedInUsername).then((userData) {
        setState(() {
          user = userData;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
      ),
      body: Center(
        child: user != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
                'Nom d\'utilisateur: ${user!.username}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
                'Nom complet: ${user!.fullName}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
                'Email: ${user!.email}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
                'Téléphone: ${user!.phoneNumber}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
                'Licence FFE: ${user!.link}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
                'Date de Naissance: ${user!.dateOfBirth.toLocal()}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user!),
                  ),
                );
              },
              child: Text('Éditer le Profil'),
            ),
          ],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UserProfile _editedUser;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer le Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _editedUser.fullName,
                decoration: InputDecoration(labelText: 'Nom complet'),
                onSaved: (value) {
                  _editedUser.fullName = value!;
                },
              ),
              TextFormField(
                initialValue: _editedUser.phoneNumber,
                decoration: InputDecoration(labelText: 'Téléphone'),
                onSaved: (value) {
                  _editedUser.phoneNumber = value!;
                },
              ),
              TextFormField(
                initialValue: _editedUser.link,
                decoration: InputDecoration(labelText: 'Licence FFE'),
                onSaved: (value) {
                  _editedUser.link = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date de naissance'),
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      _editedUser.dateOfBirth = DateTime.parse(value);
                    } catch (d) {
                      print("Erreur de conversion de date de naissance : $d");
                    }
                  }
                },
              ),

              TextFormField(
                initialValue: _editedUser.email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final emailRegex = RegExp(r"^[a-z0-9.a-z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                  if (value == null || value.isEmpty) {
                    return 'Entrez votre email';
                  } else if (!emailRegex.hasMatch(value)) {
                    return 'Entrez une adresse e-mail valide';
                  }


                  return null;
                },
                onSaved: (value) {
                  _editedUser.email = value!;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    MongoDataBase().updateUserProfile(_editedUser).then((success) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                      }
                    });
                  }
                },
                child: Text('Sauvegarder les Modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
