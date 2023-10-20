
import 'dart:io';
import 'dart:typed_data';
import 'package:andrestable/form/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';
import 'package:image_picker/image_picker.dart';

import '../page/homePage.dart';

class HorseFormModel {
  String? name;
  DateTime? birthdate;
  String? horse_dress;
  String? race;
  String? gender;
  String? speciality;
  int? isDP;
  Uint8List? image;
  String? user;
}

class HorseFormPage extends StatefulWidget {
  const HorseFormPage({super.key});

  @override
  _HorsePageState createState() => _HorsePageState();
}

class _HorsePageState extends State<HorseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginForm = HorseFormModel();
  final TextEditingController _birthdateController = TextEditingController();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxHeight: 300, maxWidth: 300);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _loginForm.image = imageBytes;
      });
    }
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
        title: const Text('Ajouter un compagnon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom de ma licorne'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de la licorne';
                  }
                  return null;
                },
                onSaved: (value) {
                  _loginForm.name = value!;
                },
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Date de naissance'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _loginForm.birthdate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null && pickedDate != _loginForm.birthdate) {
                    setState(() {
                      _loginForm.birthdate = pickedDate;
                      _birthdateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
                readOnly: true,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Robe'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la robe de la licorne';
                  }
                  return null;
                },
                onSaved: (value) {
                  _loginForm.horse_dress = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Race'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la race de la licorne';
                  }
                  return null;
                },
                onSaved: (value) {
                  _loginForm.race = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le genre de la licorne';
                  }
                  return null;
                },
                onSaved: (value) {
                  _loginForm.gender = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Spécialité de la licorne'),
                value: _loginForm.speciality,
                items: ['Dressage', 'Saut', 'Endurance', 'Complet'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _loginForm.speciality = newValue;
                  });
                },
              ),
              if (SessionManager().getLoggedInUser() == "admin")
          SwitchListTile(
          title: const Text('Licorne DP'),
      value: _loginForm.isDP == 1,
      onChanged: (value) {
        setState(() {
          _loginForm.isDP = (value ? 1 : 0);
        });
      },
    ),

              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    String? loggedInUsername = SessionManager().getLoggedInUser();
                    if (loggedInUsername == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                    var horse = {
                      'name': _loginForm.name,
                      'birthdate': _loginForm.birthdate,
                      'horse_dress': _loginForm.horse_dress,
                      'race': _loginForm.race,
                      'gender': _loginForm.gender,
                      'speciality': _loginForm.speciality,
                      'isDP': _loginForm.isDP,
                      'image': Uint8List.fromList(_loginForm.image as List<int>),
                      'user': loggedInUsername,
                    };
                    bool isValid = await MongoDataBase().addToDB(horse, "horses");
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
                child: const Text('Ajouter'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );

                },
              child: const Text('Annuler'),),

            ],
          ),

        ),
        ),
      ),

    );
  }
}

