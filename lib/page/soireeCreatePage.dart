import 'dart:typed_data';

import 'package:andrestable/page/soireePage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../database/mongodb.dart';
import 'homePage.dart';

class SoireeCreateFormModel {
  Uint8List? image;
  String? theme;
  DateTime? datetime;
  String? adresse;
  bool? typesoiree;
}


class SoireeCreatePage extends StatefulWidget {
  @override
  _PageSoireeCreateState createState() => _PageSoireeCreateState();
}

class _PageSoireeCreateState extends State<SoireeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _soireeForm = SoireeCreateFormModel();

  final TextEditingController _dateController = TextEditingController();

  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxHeight: 300, maxWidth: 300);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _soireeForm.image = imageBytes;
      });
      print(_soireeForm.image);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  List<bool> selectedCheckBoxes = [false, false];

  DateTime dateTime = DateTime(2023, 10, 18, 17, 15);

  @override
  Widget build(BuildContext context) {

    final themeController = TextEditingController();
    final adresseController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Soirée'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date et Heure'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _soireeForm.datetime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        // Combine la date sélectionnée et l'heure sélectionnée
                        DateTime selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        setState(() {
                          _soireeForm.datetime = selectedDateTime;
                          _dateController.text = "${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${pickedTime.format(context)}";
                        });
                      }
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                RadioListTile(
                  title: Text('Apéro'),
                  value: true,
                  groupValue: _soireeForm.typesoiree,
                  onChanged: (value) {
                    setState(() {
                      _soireeForm.typesoiree = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Repas'),
                  value: false,
                  groupValue: _soireeForm.typesoiree,
                  onChanged: (value) {
                    setState(() {
                      _soireeForm.typesoiree = value;
                    });
                  },
                ),
                TextFormField(
                  controller: themeController,
                  decoration: InputDecoration(labelText: 'Thème de la soirée'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le thème de votre soirée';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _soireeForm.theme = value!;
                  },
                ),
                TextFormField(
                  controller: adresseController,
                  decoration: InputDecoration(labelText: 'Adresse de la soirée'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'adresse de la soiree';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _soireeForm.adresse = value!;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      String? loggedInUsername = SessionManager().getLoggedInUser();
                      if (loggedInUsername == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => soireePage()),
                        );
                      }
                      int isVerify = 0;
                      if(loggedInUsername == 'admin'){
                        isVerify = 1;
                      }
                      var party = {
                        'image': _soireeForm.image != null ? Uint8List.fromList(_soireeForm.image!) : Uint8List(0),
                        'theme': _soireeForm.theme,
                        'datetime': _soireeForm.datetime,
                        'adresse': _soireeForm.adresse,
                        'type': _soireeForm.typesoiree == true ? 'Apéro' : 'Repas',
                        'isVerify': isVerify,
                        'user': loggedInUsername,
                      };
                      bool isValid = await MongoDataBase().addToDB(party, "partys");
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'envoyer votre demande de création de soirée pour le moment, réessayez plus tard'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Créer la Soirée'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
