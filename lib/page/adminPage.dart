import 'package:flutter/material.dart';
import '../database/mongodb.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _unverifiedParties = [];
  List<Map<String, dynamic>> _unverifiedCompetitions = [];
  List<Map<String, dynamic>> _unverifiedLessons = [];
  String? loggedInUsername = SessionManager().getLoggedInUser();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    List<Map<String, dynamic>> unverifiedParties =
    await MongoDataBase().getAdmin('partys');
    List<Map<String, dynamic>> unverifiedCompetitions =
    await MongoDataBase().getAdmin('contest');
    List<Map<String, dynamic>> unverifiedLessons =
    await MongoDataBase().getAdmin('lessons');
    setState(() {
      _unverifiedParties = unverifiedParties;
      _unverifiedCompetitions = unverifiedCompetitions;
      _unverifiedLessons = unverifiedLessons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Trois onglets pour les trois catégories d'événements
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Soirées'),
              Tab(text: 'Compétitions'),
              Tab(text: 'Cours'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryCard(
              categoryTitle: 'Soirées non vérifiées',
              itemList: _unverifiedParties,
              itemBuilder: (item) {
                return _buildEventItem(item, 'partys');
              },
            ),
            _buildCategoryCard(
              categoryTitle: 'Compétitions non vérifiées',
              itemList: _unverifiedCompetitions,
              itemBuilder: (item) {
                return _buildEventItem(item, 'contest');
              },
            ),
            _buildCategoryCard(
              categoryTitle: 'Cours non vérifiés',
              itemList: _unverifiedLessons,
              itemBuilder: (item) {
                return _buildEventItem(item, 'lessons');
              },
            ),
          ],
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

  Widget _buildEventItem(dynamic item, String collection) {
    final event = item as Map<String, dynamic>;
    final eventId = event['_id'].toString();

    return ListTile(
      title: Text('${event['theme']}'),
      subtitle: Text(
        '${event['datetime']} || ${event['adresse']} || ${event['typesoiree']}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              _acceptEvent(eventId, collection);
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              _removeEvent(eventId, collection);
            },
          ),
        ],
      ),
    );
  }

  void _acceptEvent(String eventId, String collection) {
    print('Accept Event clicked for eventId: $eventId');
    try {
      MongoDataBase().addEvent(eventId, collection);
      setState(() {
        if (collection == 'partys') {
          _unverifiedParties.removeWhere((event) => event['_id'].toString() == eventId);
        } else if (collection == 'contest') {
          _unverifiedCompetitions.removeWhere((event) => event['_id'].toString() == eventId);
        } else if (collection == 'lessons') {
          _unverifiedLessons.removeWhere((event) => event['_id'].toString() == eventId);
        }
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'événement : $e');
    }
  }

  void _removeEvent(String eventId, String collection) {
    print('Remove Event clicked for eventId: $eventId');
    try {
      MongoDataBase().removeEvent(eventId, collection);
      setState(() {
        if (collection == 'partys') {
          _unverifiedParties.removeWhere((event) => event['_id'].toString() == eventId);
        } else if (collection == 'contest') {
          _unverifiedCompetitions.removeWhere((event) => event['_id'].toString() == eventId);
        } else if (collection == 'lessons') {
          _unverifiedLessons.removeWhere((event) => event['_id'].toString() == eventId);
        }
      });
    } catch (e) {
      print('Erreur lors de la suppression de l\'événement : $e');
    }
  }
}
