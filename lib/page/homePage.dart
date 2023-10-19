import 'dart:typed_data';
import 'package:andrestable/page/contest.dart';
import 'package:andrestable/page/horseFormPage.dart';
import 'package:andrestable/page/soireeCreatePage.dart';
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
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _contest = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    List<Map<String, dynamic>> recentHorses = await MongoDataBase().getLast("horses");
    List<Map<String, dynamic>> parties = await MongoDataBase().get("partys");
    List<Map<String, dynamic>> lessons = await MongoDataBase().get("lessons");
    List<Map<String, dynamic>> contest = await MongoDataBase().get("contests");

    setState(() {
      _lastHorses = recentHorses;
      _parties = parties;
      _lessons = lessons;
      _contest = contest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.pinkAccent),
              title: const Text('Ajouter un compagnon'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HorseFormPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
              title: const Text('Ajouter une soirée'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SoireeCreatePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.pinkAccent),
              title: const Text('Ajouter une leçon'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LessonsFormPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.pinkAccent),
              title: const Text('Ajouter une compétition'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContestFormPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Section pour les chevaux
              _buildCategoryCard(
                categoryTitle: 'Dernière Licornes',
                itemList: _lastHorses,
                itemBuilder: (item) {
                  final horse = item as Map<String, dynamic>;
                  Uint8List imageBytes = Uint8List.fromList(List<int>.from(horse['image']));
                  return ListTile(
                    title: Text('Nom de la licorne: ${horse['name']}'),
                    subtitle: Text('Nom du créateur: ${horse['user']}'),
                    leading: imageBytes != null
                        ? Image.memory(imageBytes)
                        : const Icon(Icons.add_a_photo),
                  );
                },
              ),

              // Section pour les soirées
              _buildCategoryCard(
                categoryTitle: 'Soirées',
                itemList: _parties,
                itemBuilder: (item) {
                  final party = item as Map<String, dynamic>;
                  return ListTile(
                    title: Text('${party['theme']}'),
                    subtitle: Text('${party['datetime']} || ${party['adresse']} || ${party['typesoiree']}'),
                  );
                },
              ),

              // Section pour les leçons
              _buildCategoryCard(
                categoryTitle: 'Leçons',
                itemList: _lessons,
                itemBuilder: (item) {
                  final lessons = item as Map<String, dynamic>;
                  return ListTile(
                    title: Text('Leçon de ${lessons['discipline']}'),
                    subtitle: Text('${lessons['dateTime']} || ${lessons['place']} || ${lessons['duration']}'),
                  );
                },
              ),

              // Section pour les compétitions
              _buildCategoryCard(
                categoryTitle: 'Compétitions',
                itemList: _contest,
                itemBuilder: (item) {
                  final contest = item as Map<String, dynamic>;
                  Uint8List imageBytes = Uint8List.fromList(List<int>.from(contest['image']));
                  return ListTile(
                    title: Text('Compétition : ${contest['name']}'),
                    subtitle: Text('${contest['datetime']} || ${contest['adress']}'),
                    leading: imageBytes != null
                        ? Image.memory(imageBytes)
                        : const Icon(Icons.add_a_photo),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String categoryTitle,
    required List<Map<String, dynamic>> itemList,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            if (itemList.isNotEmpty)
              Column(
                children: itemList.map((item) {
                  return itemBuilder(item);
                }).toList(),
              )
            else
              const Text('Aucun élément dans cette catégorie.'),
          ],
        ),
      ),
    );
  }
}
