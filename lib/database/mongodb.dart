import 'dart:developer';
import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDataBase {
  static late Db _db;
  static late DbCollection _collection;

  static connect() async{
      _db = await Db.create(MONGO_URL);
      await _db.open();


  }
  Future<bool> verifyLog(String username, String password, String collection) async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.findOne({
      'username': username,
      'password': password,
    });
    return result != null;
  }

  Future<bool> addToDB(Map<String, dynamic> data, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.insert(data);
    return result != null;
  }

  Future<List<Map<String, dynamic>>> getLastHorses() async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection("horses");
    var result = await _collection.find(where.sortBy('_id', descending: true).limit(10));
    List<Map<String, dynamic>> lastHorses = [];
    await for (var horse in result) {
      lastHorses.add(Map<String, dynamic>.from(horse));
    }
    return lastHorses;
  }

  Future<bool> verifyPw(String username, String email, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);

    var result = await _collection.find({
      'username': username,
      'email': email,
    });
    return result != null;
  }
  Future<bool> changePw(String username, String email, String password, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.update(
      where.eq('username', username).eq('email', email),
      modify.set('password', password),
    );

    return result != null;
  }

  Future<List<Map<String, dynamic>>?> getUnverifiedPartys() async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection('partys');

    final query = where.eq('isVerify', 0);
    final result = await _collection.find(query).toList();

    if (result.isNotEmpty) {
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return null;
    }
  }

  Future<bool> changePartyVerificationStatus(String partyId, int newStatus) async {
    try {
      if (_db == null) {
        throw Exception('La connexion à la base de données n\'a pas été établie.');
      }

      final partyCollection = _db.collection('partys');

      final result = await partyCollection.update(
        where.eq('_id', partyId),
        modify.set('isVerify', newStatus == 1),
      );

      return result != null && (result['ok'] == 1 || result['updatedExisting'] == true);
    } catch (e) {
      print("Erreur lors de la mise à jour de l'état de validation de la soirée : $e");
      return false;
    }
  }

  Future<void> deletePartyById(String id) async {
    final collection = _db.collection('partys');
    await collection.remove(where.eq('_id', ObjectId.fromHexString(id)));
  }

}

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  String? loggedInUser;

  void setLoggedInUser(String user) {
    loggedInUser = user;
  }

  String? getLoggedInUser() {
    return loggedInUser;
  }

}



