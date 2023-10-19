import 'dart:developer';
import 'dart:typed_data';
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
  Future<bool> addUserToDB(Map<String, dynamic> users, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    print(users);
    var result = await _collection.insert(users);
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

  Future<List<Map<String, dynamic>>> getEmail() async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection("users");
    var result = await _collection.find(where.sortBy('email', descending: true));
    List<Map<String, dynamic>> lastEmail = [];
    await for (var email in result) {
      lastEmail.add(Map<String, dynamic>.from(email));
    }
    return lastEmail;
  }
  Future<List<Map<String, dynamic>>> getUsername() async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection("users");
    var result = await _collection.find(where.sortBy('username', descending: true).limit(10));
    List<Map<String, dynamic>> lastHorses = [];
    await for (var horse in result) {
      lastHorses.add(Map<String, dynamic>.from(horse));
    }
    return lastHorses;
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