import 'dart:typed_data';
import 'package:andrestable/form/contest.dart';
import 'package:andrestable/form/horseFormPage.dart';
import 'package:andrestable/form/profileFormPage.dart';
import 'package:andrestable/form/soireeCreatePage.dart';
import 'package:andrestable/form/lessonsFormPage.dart';
import 'package:andrestable/page/participations.dart';
import 'package:flutter/material.dart';
import '../database/mongodb.dart';
import 'adminPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, bool> userParticipation = {};
  List<Map<String, dynamic>> _lastHorses = [];
  List<Map<String, dynamic>> _parties = [];
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _contest = [];
  String? loggedInUsername = SessionManager().getLoggedInUser();
  Map<String, EventData> eventDataMap = {};

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

    await Future.forEach(parties, (party) async {
      final eventId = party['_id'].toString();
      final isParticipating = await MongoDataBase().isUserParticipatingInEvent(eventId, loggedInUsername!, 'partys');
      eventDataMap[eventId] = EventData(party, isParticipating);
    });

    await Future.forEach(lessons, (lesson) async {
      final eventId = lesson['_id'].toString();
      final isParticipating = await MongoDataBase().isUserParticipatingInEvent(eventId, loggedInUsername!, 'lessons');
      eventDataMap[eventId] = EventData(lesson, isParticipating);
    });

    await Future.forEach(contest, (cont) async {
      final eventId = cont['_id'].toString();
      final isParticipating = await MongoDataBase().isUserParticipatingInEvent(eventId, loggedInUsername!, 'contests');
      eventDataMap[eventId] = EventData(cont, isParticipating);
    });


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
              leading: const Icon(Icons.person, color: Colors.pinkAccent),
              title: const Text('Mon profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.accessibility, color: Colors.pinkAccent),
              title: const Text('Mes participations'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEventsPage(),
                  ),
                );
              },
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
            if(loggedInUsername == 'admin')
              ListTile(
                leading: const Icon(Icons.star, color: Colors.pinkAccent),
                title: const Text('Accès Admin'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPage()
                      ,
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
                    onTap: () {
                      _showHorseInfoPopup(horse);
                    },
                  );
                },
              ),

              _buildCategoryCard(
                categoryTitle: 'Soirées',
                itemList: _parties,
                itemBuilder: (item){
                  final party = item as Map<String, dynamic>;
                  final eventId = party['_id'].toString();
                  final eventData = eventDataMap[eventId];
                  final isParticipating = eventData?.isUserParticipating ?? false;
                  return ListTile(
                      title: Text('${party['theme']}'),
                      subtitle: Text('${party['datetime']} || ${party['adresse']} || ${party['typesoiree']}'),
                      leading: isParticipating
                          ? const Icon(
                        Icons.check_box,
                        color: Colors.green,
                      )
                          : const Icon(
                        Icons.check_box_outline_blank,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showPartyInfoPopup(party);

                        setState(() {
                          userParticipation[eventId] = !isParticipating;
                          if (isParticipating) {
                            MongoDataBase().removeParticipant(
                                eventId, loggedInUsername!, 'partys');
                          } else {
                            MongoDataBase().addParticipant(eventId, loggedInUsername!, 'partys');
                          }
                        });
                      }
                  );
                },
              ),

              _buildCategoryCard(
                categoryTitle: 'Leçons',
                itemList: _lessons,
                itemBuilder: (item) {
                  final lessons = item as Map<String, dynamic>;
                  final eventId = lessons['_id'].toString();
                  final eventData = eventDataMap[eventId];
                  final isParticipating = eventData?.isUserParticipating ?? false;
                  return ListTile(
                      title: Text('Leçon de ${lessons['discipline']}'),
                      subtitle: Text('${lessons['dateTime']} || ${lessons['place']} || ${lessons['duration']}'),
                      leading: isParticipating
                          ? const Icon(
                        Icons.check_box,
                        color: Colors.green,
                      )
                          : const Icon(
                        Icons.check_box_outline_blank,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showLessonInfoPopup(lessons);

                        setState(() {
                          userParticipation[eventId] = !isParticipating;
                          if (isParticipating) {
                            MongoDataBase().removeParticipant(
                                eventId, loggedInUsername!, 'lessons');
                          } else {
                            MongoDataBase().addParticipant(eventId, loggedInUsername!, 'lessons');
                          }
                        });
                      }
                  );
                },
              ),

              _buildCategoryCard(
                categoryTitle: 'Compétitions',
                itemList: _contest,
                itemBuilder: (item) {
                  final contest = item as Map<String, dynamic>;
                  final eventId = contest['_id'].toString();
                  final isParticipating = userParticipation[eventId] ?? false;
                  Uint8List imageBytes = Uint8List.fromList(List<int>.from(contest['image']));
                  return ListTile(
                      title: Text('Compétition : ${contest['name']}'),
                      subtitle: Text('${contest['datetime']} || ${contest['adress']}'),
                      leading: isParticipating
                          ? const Icon(
                        Icons.check_box,
                        color: Colors.green,
                      )
                          : const Icon(
                        Icons.check_box_outline_blank,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showContestInfoPopup(contest);

                        setState(() {
                          userParticipation[eventId] = !isParticipating;
                          if (isParticipating) {
                            MongoDataBase().removeParticipant(
                                eventId, loggedInUsername!, 'contests');
                          } else {
                            MongoDataBase().addParticipant(eventId, loggedInUsername!, 'contests');
                          }
                        });
                      }
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
  void _showHorseInfoPopup(Map<String, dynamic> horse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informations sur la licorne : ${horse['name']}',
            style: const TextStyle(
              color: Colors.pink,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nom de la licorne : ${horse['name']}'),
              Text('Nom du créateur : ${horse['user']}'),
              Text('Date d\'anniverssaire : ${horse['birthdate']}'),
              Text('Race : ${horse['race']}'),
              Text('Genre : ${horse['gender']}'),
              Text('Demi-Pension : ${horse['isDP']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer',
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPartyInfoPopup(Map<String, dynamic> party) {
    String comment = '';
    List<dynamic> comments = (party['comments'] as List<dynamic>? ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Informations sur la soirée',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Thème : ${party['theme']}'),
                  Text('Date et Heure : ${party['datetime']}'),
                  Text('Adresse : ${party['adresse']}'),
                  Text('Type de soirée : ${party['typesoiree']}'),
                  Text('Demande de : ${party['user']}'),
                  Text('Commentaires :'),
                  if (comments.isNotEmpty)
                    Column(
                      children: comments.map((commentData) {
                        return Text('${commentData['username']}: ${commentData['comment']}');
                      }).toList(),
                    ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Ajouter un commentaire'),
                    onChanged: (text) {
                      setState(() {
                        comment = text;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (comment.isNotEmpty) {
                      await MongoDataBase().addComment(party['_id'].toString(), loggedInUsername!, comment, 'partys');
                      comments.add({'username': loggedInUsername, 'comment': comment});
                      setState(() {
                        comment = '';
                      });
                    }
                  },
                  child: const Text(
                    'Ajouter un commentaire',
                    style: TextStyle(
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showLessonInfoPopup(Map<String, dynamic> lessons) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informations sur la leçon',
            style: TextStyle(
              color: Colors.pink,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lieu : ${lessons['place']}'),
              Text('Date et Heure : ${lessons['datetime']}'),
              Text('Durée : ${lessons['duration']}'),
              Text('Discipline : ${lessons['discipline']}'),
              Text('Demande de : ${lessons['user']}'),
              Text('Participants : ${lessons['participants']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer',
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContestInfoPopup(Map<String, dynamic> contest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informations sur la compétition',
            style: TextStyle(
              color: Colors.pink,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nom : ${contest['name']}'),
              Text('Adresse : ${contest['adress']}'),
              Text('Date et Heure : ${contest['datetime']}'),
              Text('Demande de : ${contest['user']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer',
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EventData {
  final Map<String, dynamic> eventInfo;
  final bool isUserParticipating;

  EventData(this.eventInfo, this.isUserParticipating);
}