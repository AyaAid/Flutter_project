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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nom d\'utilisateur: ${user!.username}'),
            Text('Nom complet: ${user!.fullName}'),
            Text('Email: ${user!.email}'),
            Text('Téléphone: ${user!.phoneNumber}'),
            Text('Licence FFE: ${user!.link}'),
            Text('Date de Naissance: ${user!.dateOfBirth.toLocal()}'),
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
                initialValue: _editedUser.email,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) {
                  _editedUser.email = value!;
                },
              ),
              // Ajoutez d'autres champs ici
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
