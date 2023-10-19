
import 'dart:io';
import 'dart:typed_data';
import 'package:andrestable/page/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:andrestable/database/mongodb.dart';
import 'package:image_picker/image_picker.dart';

import 'homePage.dart';

class LessonsFormModel {
  String? place;
  DateTime? dateTime;
  String? duration;
  String? discipline;
  bool? isVerify;
  String? user;
}

class LessonsFormPage extends StatefulWidget {
  const LessonsFormPage({super.key});

  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _lessonsForm = LessonsFormModel();
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une leçon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Lieu de la leçon'),
                  value: _lessonsForm.place,
                  items: ['Carrière', 'Manège'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _lessonsForm.place = newValue;
                    });
                  },
                ),
                TextFormField(
                  controller: _dateTimeController,
                  decoration: const InputDecoration(labelText: 'Date et heure'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _lessonsForm.dateTime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        DateTime selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        setState(() {
                          _lessonsForm.dateTime = selectedDateTime;
                          _dateTimeController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}";
                        });
                      }
                    }

                  },
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Durée de la leçon'),
                  value: _lessonsForm.duration,
                  items: ['30 min', '1h', '2h', '3h', '4h', '5h'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _lessonsForm.duration = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Discipline enseigné'),
                  value: _lessonsForm.discipline,
                  items: ['Dressage', 'Saut d\'obstacle', 'Endurance'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _lessonsForm.discipline = newValue;
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
                      int isValidate = 0;
                      if(loggedInUsername == 'admin'){
                        isValidate = 1;
                      }
                      var horse = {
                        'place': _lessonsForm.place,
                        'dateTime': _lessonsForm.dateTime,
                        'duration': _lessonsForm.duration,
                        'discipline': _lessonsForm.discipline,
                        'isVerify': isValidate,
                        'user': loggedInUsername,
                      };
                      bool isValid = await MongoDataBase().addToDB(horse, "lessons");
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'ajouter votre leçon pour le moment, réessayez plus tard'),
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

