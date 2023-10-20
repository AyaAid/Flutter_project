
import 'dart:io';
import 'dart:typed_data';
import 'package:andrestable/form/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';
import 'package:image_picker/image_picker.dart';

import '../page/homePage.dart';

class ContestFormModel {
  String? name;
  String? adress;
  Uint8List? image;
  DateTime? datetime;
  bool? isVerify;
  String? user;
}

class ContestFormPage extends StatefulWidget {
  const ContestFormPage({super.key});

  @override
  _ContestPageState createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _contestForm = ContestFormModel();
  final TextEditingController datetimeController = TextEditingController();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxHeight: 300, maxWidth: 300);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _contestForm.image = imageBytes;
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
        title: const Text('Ajouter une compétition'),
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
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  )
                      : Image.file(_image!),
                ),

                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nom de la compétition'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de la compétition';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contestForm.name = value!;
                  },
                ),

                TextFormField(
                  decoration: const InputDecoration(labelText: 'Adresse de la compétition'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'adresse de la compétition';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contestForm.adress = value!;
                  },
                ),

                TextFormField(
                  controller: datetimeController,
                  decoration: const InputDecoration(labelText: 'Date de l\'événement'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _contestForm.datetime ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null && pickedDate != _contestForm.datetime) {
                      setState(() {
                        _contestForm.datetime = pickedDate;
                        datetimeController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  readOnly: true,
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
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      }
                      int isVerified = 0;
                      if(loggedInUsername == 'admin'){
                        isVerified = 1;
                      }
                      var contest = {
                        'name': _contestForm.name,
                        'adress': _contestForm.adress,
                        'datetime': _contestForm.datetime,
                        'image': _contestForm.image != null ? Uint8List.fromList(_contestForm.image as List<int>) : null,
                        'isVerify': isVerified,
                        'user': loggedInUsername,
                      };
                      bool isValid = await MongoDataBase().addToDB(contest, "contests");
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'ajouter votre compétition pour le moment, réessayez plus tard'),
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
                      MaterialPageRoute(builder: (context) => const HomePage()),
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

