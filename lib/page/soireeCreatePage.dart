import 'dart:ffi';

import 'package:andrestable/page/soireePage.dart';
import 'package:flutter/material.dart';
import '../database/mongodb.dart';
import 'homePage.dart';

class SoireeCreateFormModel {
  String? theme;
  DateTime? datetime;
  String? adresse;
  String? typesoiree;
  bool? isVerify;
  String? user;
  List<String>? participants;
}

class SoireeCreatePage extends StatefulWidget {
  @override
  _PageSoireeCreateState createState() => _PageSoireeCreateState();
}

class _PageSoireeCreateState extends State<SoireeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _soireeForm = SoireeCreateFormModel();

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _soireeForm.typesoiree = 'Apéro';
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

    String imageUrl = _soireeForm.typesoiree == 'Apéro'
        ? 'https://www.domaine-picard.com/blog/wp-content/uploads/2020/09/planche-ap%C3%A9ro-gourmande-980x980.jpg'
        : 'https://www.deco.fr/sites/default/files/styles/article_970x500/public/2022-03/shutterstock_1685806537.jpg?itok=p7o3Z5h2';

    Image image = Image.network(
      imageUrl,
      width: 500,
      height: 500,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Soirée'),
      ),
      body: Center(
        child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image,
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
                  value: 'Apéro',
                  groupValue: _soireeForm.typesoiree,
                  onChanged: (value) {
                    setState(() {
                      _soireeForm.typesoiree = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Repas'),
                  value: 'Repas',
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
                        'theme': _soireeForm.theme,
                        'datetime': _soireeForm.datetime,
                        'adresse': _soireeForm.adresse,
                        'typesoiree': _soireeForm.typesoiree,
                        'isVerify': isVerify,
                        'user': loggedInUsername,
                        'participants': _soireeForm.participants ?? []..add(loggedInUsername!),
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
      ),
    );
  }
}
