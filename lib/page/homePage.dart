import 'dart:typed_data';
import 'package:andrestable/page/contest.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchRecentHorses();
  }

  Future<void> _fetchRecentHorses() async {
    List<Map<String, dynamic>> recentHorses = await MongoDataBase().getLastHorses();

    setState(() {
      _lastHorses = recentHorses;
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

              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContestFormPage()),);
                },
                child: const Text('Ajouter une compétition'),
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
                          : Icon(Icons.image),
                    );
                  },
                )
              ),
            ],)
      ),
    );
  }
}

