import 'package:flutter/material.dart';
import '../database/mongodb.dart';

class GerantPage extends StatefulWidget {
  @override
  _GerantPageState createState() => _GerantPageState();
}

class _GerantPageState extends State<GerantPage> {
  List<Map<String, dynamic>>? unverifiedPartys;

  MongoDataBase db = MongoDataBase();

  @override
  void initState() {
    super.initState();
    loadUnverifiedPartys();
  }

  void loadUnverifiedPartys() async {
    try {
      final parties = await db.getUnverifiedPartys();
      if (parties != null) {
        unverifiedPartys = parties;
      }
      setState(() {});
    } catch (e) {
      print("Erreur lors du chargement des données : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes de soirées'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              Text("Liste des demandes de soirées non vérifiées"),
              Expanded(
                child: unverifiedPartys == null
                    ? CircularProgressIndicator()
                    : unverifiedPartys!.isEmpty
                    ? Text("Aucune demande de soirée non vérifiée.")
                    : ListView.builder(
                  itemCount: unverifiedPartys!.length,
                  itemBuilder: (context, index) {
                    final party = unverifiedPartys![index];
                    return Card(
                      child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Thème : ${party['theme']}"),
                            Text("Date et Heure : ${party['datetime']}"),
                            Text("Adresse : ${party['adresse']}"),
                            Text("Type de Soirée : ${party['typesoiree']}"),
                            Text("Auteur : ${party['user']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                party['isVerify'] = 1;

                                db.changePartyVerificationStatus(party['_id'], 1);

                                setState(() {
                                  loadUnverifiedPartys;
                                });
                              },
                              child: Text('Valider'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final idToRemove = party['_id'];

                                await db.deletePartyById(idToRemove);

                                final unverifiedPartys = this.unverifiedPartys;
                                if (unverifiedPartys != null) {
                                  unverifiedPartys.removeWhere((party) => party['_id'] == idToRemove);
                                }

                                setState(() {});
                              },
                              child: Text('Refuser'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
