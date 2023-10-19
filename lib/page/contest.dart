
import 'dart:io';
import 'dart:typed_data';
import 'package:andrestable/page/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';
import 'package:image_picker/image_picker.dart';

import 'homePage.dart';

class ContestFormModel {
  String? name;
  String? adress;
  Uint8List? image;
  DateTime? datetime;
}

class ContestFormPage extends StatefulWidget {
  const ContestFormPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<ContestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginForm = ContestFormModel();
  final TextEditingController datetimeController = TextEditingController();
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
    datetimeController.dispose();
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
                      return 'Veuillez entrer le nom de la compétition';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _loginForm.name = value!;
                  },
                ),

                TextFormField(
                  controller: datetimeController,
                  decoration: const InputDecoration(labelText: 'Date de l\'événement'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _loginForm.datetime ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null && pickedDate != _loginForm.datetime) {
                      setState(() {
                        _loginForm.datetime = pickedDate;
                        datetimeController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  readOnly: true,
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
                      int isDP = 0;
                      if(loggedInUsername == 'admin'){
                        isDP = 1;
                      }
                      var contest = {
                        'name': _loginForm.name,
                        'datetime': _loginForm.datetime,
                        'horse_dress': _loginForm.horse_dress,
                        'race': _loginForm.race,
                        'gender': _loginForm.gender,
                        'speciality': _loginForm.speciality,
                        'isDP': isDP,
                        'image': _loginForm.image,
                      };
                      bool isValid = await MongoDataBase().addHorseToDB(horse, "horses");
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

