import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../database/mongodb.dart';
import '../database/constant.dart';
import 'PageSoireeVerify.dart';

class SoireeCreateFormModel {
  Uint8List? image;
  String? theme;
  DateTime? datetime;
  String? adresse;
  bool? apero;
  bool? repas;
  bool? isVerify;
}

class PageSoireeCreate extends StatefulWidget {
  @override
  _PageSoireeCreateState createState() => _PageSoireeCreateState();
}

class _PageSoireeCreateState extends State<PageSoireeCreate> {
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

  bool aperoValue = false;
  bool repasValue = false;
  List<bool> selectedCheckBoxes = [false, false];

  DateTime dateTime = DateTime(2023, 10, 18, 17, 15);

  @override
  Widget build(BuildContext context) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');

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
              mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments verticalement
              crossAxisAlignment: CrossAxisAlignment.center, // Centre les éléments horizontalement
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
                  decoration: const InputDecoration(labelText: 'Date de naissance'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _soireeForm.datetime ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null && pickedDate != _soireeForm.datetime) {
                      setState(() {
                        _soireeForm.datetime = pickedDate;
                        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  readOnly: true,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Apéro : '),
                    Checkbox(
                      value: aperoValue,
                      checkColor: Colors.white,
                      activeColor: Colors.pinkAccent,
                      onChanged: (bool? value) {
                        setState(() {
                          aperoValue = value!;

                          var isChecked = "";
                          if (aperoValue == true) {
                            isChecked = "checked";
                            _soireeForm.apero = true;
                          } else {
                            isChecked = "un-checked";
                            _soireeForm.apero = false;
                          }
                          selectedCheckBoxes[0] = aperoValue;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Repas : '),
                    Checkbox(
                      value: repasValue,
                      checkColor: Colors.white,
                      activeColor: Colors.pinkAccent,
                      onChanged: (bool? value) {
                        setState(() {
                          repasValue = value!;

                          var isChecked = "";
                          if (repasValue == true) {
                            isChecked = "checked";
                            _soireeForm.repas = true;
                          } else {
                            isChecked = "un-checked";
                            _soireeForm.repas = false;
                          }
                          selectedCheckBoxes[1] = repasValue;
                        });
                      },
                    ),
                  ],
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
                          MaterialPageRoute(builder: (context) => PageSoireeVerify()),
                        );
                      }
                      int isVerify = 0;
                      if(loggedInUsername == 'admin'){
                        isVerify = 1;
                      }
                      var party = {
                        'image': Uint8List.fromList(_soireeForm.image as List<int>),
                        'theme': _soireeForm.theme,
                        'datetime': _soireeForm.datetime,
                        'adresse': _soireeForm.adresse,
                        'apero': _soireeForm.apero,
                        'repas': _soireeForm.repas,
                        'isVerify': _soireeForm.isVerify,
                      };
                      bool isValid = await MongoDataBase().addHorseToDB(party, "partys");
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PageSoireeVerify()),
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
