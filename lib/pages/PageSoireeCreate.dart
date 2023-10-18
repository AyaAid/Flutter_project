import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PageSoireeCreate extends StatefulWidget {
  @override
  _PageSoireeCreateState createState() => _PageSoireeCreateState();
}

class _PageSoireeCreateState extends State<PageSoireeCreate> {
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100, maxHeight: 1200, maxWidth: 1200);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool aperoValue = false;
  bool repasValue = false;
  List<bool> selectedCheckBoxes = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Soirée'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: _image == null
                    ? Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                )
                    : Image.file(_image!),
              ),
              // Autres champs du formulaire (thème, date, adresse, apéro, repas, etc.)
              TextFormField(
                decoration: InputDecoration(labelText: 'Thème de la soirée'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date de la soirée'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresse de la soirée'),
              ),
              Row(
                children: [
                  Text('Apéro : '),
                  Checkbox(
                    value: aperoValue,
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    onChanged: (bool? value){
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
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Text('Repas : '),
                  Checkbox(
                      value: repasValue,
                      checkColor: Colors.white,
                      activeColor: Colors.green,
                      onChanged: (bool? value){
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
                  )
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Traitement pour soumettre la soirée à la base de données MongoDB
                },
                child: Text('Créer la Soirée'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
