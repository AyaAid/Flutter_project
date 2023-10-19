import 'dart:typed_data';
import 'package:andrestable/page/horseFormPage.dart';
import 'package:andrestable/page/soireeCreatePage.dart';
import 'package:andrestable/page/soireePage.dart';
import 'package:andrestable/page/lessonsFormPage.dart';
import 'package:flutter/material.dart';

import '../database/mongodb.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _lastHorses = [];
  List<Map<String, dynamic>> _parties = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    List<Map<String, dynamic>> recentHorses = await MongoDataBase().getLast("horses");
    List<Map<String, dynamic>> parties = await MongoDataBase().get("partys");

    setState(() {
      _lastHorses = recentHorses;
      _parties = parties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HorseFormPage()
                    ),
                  );
                },
                child: const Text('Ajouter un compagnon'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SoireeCreatePage()
                    ),
                  );
                },
                child: const Text('Ajouter une soirée'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LessonsFormPage()),);
                },
                child: const Text('Ajouter une leçon'),


              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: ListView.builder(

                  itemCount: _lastHorses.length,
                  itemBuilder: (context, index) {
                    final horse = _lastHorses[index];

                    Uint8List imageBytes = Uint8List.fromList(List<int>.from(horse['image']));


                    return ListTile(
                      title: Text('Nom du cheval: ${horse['name']}'),
                      subtitle: Text('Nom du créateur: ${horse['user']}'),
                      leading: imageBytes != null
                          ? Image.memory(imageBytes)
                          : const Icon(Icons.image),
                    );
                  },
                )
              ),
              Expanded(
                  child: ListView.builder(

                    itemCount: _parties.length,
                    itemBuilder: (context, index) {
                      final party = _parties[index];

                      Uint8List imageBytes = Uint8List.fromList(List<int>.from(party['image']));


                      return ListTile(
                        title: Text('${party['theme']}'),
                        subtitle: Text('${party['datetime']} || ${party['adresse']} || ${party['repas']}'),
                        leading: imageBytes != null
                            ? Image.memory(imageBytes)
                            : const Icon(Icons.image),
                      );
                    },
                  )
              ),
            ],)
      ),
    );
  }
}

