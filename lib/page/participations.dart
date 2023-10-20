import 'package:flutter/material.dart';
import '../database/mongodb.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key});

  @override
  _UserEventsPageState createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  List<Map<String, dynamic>> partyEvents = [];
  List<Map<String, dynamic>> contestEvents = [];
  List<Map<String, dynamic>> lessonEvents = [];

  @override
  void initState() {
    super.initState();
    final loggedInUser = SessionManager().getLoggedInUser();
    fetchUserEvents(loggedInUser!, 'partys', partyEvents);
    fetchUserEvents(loggedInUser!, 'contests', contestEvents);
    fetchUserEvents(loggedInUser!, 'lessons', lessonEvents);
  }

  Future<void> fetchUserEvents(
      String username,
      String collection,
      List<Map<String, dynamic>> targetList,
      ) async {
    List<Map<String, dynamic>> events =
    await MongoDataBase().getEventsForUser(username, collection);
    setState(() {
      targetList.addAll(events);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes participations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Soirées'),
              Tab(text: 'Compétitions'),
              Tab(text: 'Cours'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventList(partyEvents),
            _buildEventList(contestEvents),
            _buildEventList(lessonEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    return events.isNotEmpty
        ? ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        if (event.containsKey('theme')) {
          return ListTile(
            title: Text('${event['theme']}'),
            subtitle: Text('Date: ${event['datetime']}'),
          );
        } else if (event.containsKey('discipline')) {
          return ListTile(
            title: Text('${event['discipline']}'),
            subtitle: Text('Date: ${event['datetime']}'),
          );
        } else if (event.containsKey('name')) {
          return ListTile(
            title: Text('${event['name']}'),
            subtitle: Text('Date: ${event['datetime']}'),
          );
        }
        return ListTile(
          title: Text('Unknown Event'),
          subtitle: Text('Date: ${event['datetime']}'),
        );
      },
    )
        : const Center(
      child: Text('Aucun événement trouvé.'),
    );
  }


}
