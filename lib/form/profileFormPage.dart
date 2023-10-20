import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../database/mongodb.dart';
import 'dart:io';
import 'dart:convert';
import 'package:andrestable/page/homePage.dart';
import '../form/editFormHorsePage.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class UserProfile {
  String username;
  String email;
  String fullName;
  String phoneNumber;
  String link;
  DateTime dateOfBirth;
  Uint8List? image;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.link,
    required this.dateOfBirth,
    required this.image,
  });
}


class MonProfilePage extends StatefulWidget {
  @override
  _MonProfilePageState createState() => _MonProfilePageState();
}

class _MonProfilePageState extends State<MonProfilePage> {
  UserProfile? user;
  HorseProfile? horse;
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHorseProfilePage(horse: horse!),
                  ),
                );
              },
              child: Text('Éditer le Profil de mon cheval'),
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
  final TextEditingController _birthdateController = TextEditingController();
  late UserProfile _editedUser;
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxHeight: 300, maxWidth: 300);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _editedUser.image = imageBytes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  @override
  void dispose() {
    _birthdateController.dispose();
    super.dispose();
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
                initialValue: _editedUser.username,
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) {
                  _editedUser.username = value!;
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
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Date de naissance'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _editedUser.dateOfBirth ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null && pickedDate != _editedUser.dateOfBirth) {
                    setState(() {
                      _editedUser.dateOfBirth = pickedDate;
                      _birthdateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
                readOnly: true,
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

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    MongoDataBase().updateUserProfile(_editedUser).then((success) {
                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                      return ('Sauvegarde effectuée !');
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
