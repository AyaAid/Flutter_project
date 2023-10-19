import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../database/mongodb.dart';
import 'PageSoireeVerify.dart';

class PageSoireeCreate extends StatefulWidget {
  @override
  _PageSoireeCreateState createState() => _PageSoireeCreateState();
}

class _PageSoireeCreateState extends State<PageSoireeCreate> {
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 540,
      maxWidth: 960,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool aperoValue = false;
  bool repasValue = false;
  List<bool> selectedCheckBoxes = [false, false];

  DateTime dateTime = DateTime(2023, 10, 18, 17, 15);

  @override
  Widget build(BuildContext context) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Soirée'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments verticalement
              crossAxisAlignment: CrossAxisAlignment.center, // Centre les éléments horizontalement
              children: [
                GestureDetector(
                  onTap: _getImage,
                  child: _image == null
                      ? Container(
                    width: 200,
                    height: 200,
                    color: Colors.pinkAccent,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  )
                      : Image.file(_image!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Date et Heure',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments horizontalement dans le Row
                  children: [
                    ElevatedButton(
                      child: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
                      onPressed: () async {
                        final date = await pickDate();
                        if (date == null) return; // Annuler

                        setState(() => dateTime = date); // Ok
                      },
                    ),
                    SizedBox(width: 16), // Espace entre les boutons
                    ElevatedButton(
                      child: Text('$hours:$minutes'),
                      onPressed: () async {
                        final time = await pickTime();
                      },
                    ),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Thème de la soirée'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Adresse de la soirée'),
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
                          } else {
                            isChecked = "un-checked";
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
                          } else {
                            isChecked = "un-checked";
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
                    // Effectuez l'enregistrement des informations dans la base de données MongoDB
                    await saveSoireeToMongoDB();

                    // Redirigez l'utilisateur vers une autre page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageSoireeVerify()), // Remplacez AttenteValidationPage() par le nom de votre écran de validation
                    );
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

  Future<DateTime?> pickDate() => showDatePicker(
    context: context,
    initialDate: dateTime,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
  );

  Future<void> saveSoireeToMongoDB() async {
    await MongoDataBase.connect();

    final dataToInsert = {
      'theme': 'Thème de la soirée',
      'adresse': 'Adresse de la soirée',
      'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
      'heure': '$hours:$minutes',
      'apero': aperoValue,
      'repas': repasValue,
    };
    await MongoDataBase.insertData(dataToInsert);
  }
}
