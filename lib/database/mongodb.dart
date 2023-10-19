import 'dart:developer';
import 'dart:typed_data';
import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDataBase {
  static late Db _db;
  static late DbCollection _collection;

  static connect() async {
    _db = await Db.create(MONGO_URL);
    await _db.open();
    inspect(_db);
    _collection = _db.collection(COLLECTION_NAME);
  }

  Future<bool> verifyLog(String username, String password) async {
    if (_db == null || _collection == null) {
      throw Exception(
          'La connexion à la base de données n\'a pas été établie.');
    }

    var result = await _collection.findOne({
      'username': username,
      'password': password,
    });
    return result != null;
  }
  Future<bool> createUser( String username, String mail, String password, Uint8List image) async{
    if (_db == null || _collection == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    var result = await _collection.insertOne({
      'username': username,
      'password': password,
      'email': mail,
      'image': image
  });
    return result != null;
  }
  Future<bool> addUserToDB(Map<String, dynamic> users, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.insert(users);
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
  Future<String> getUsername(String username) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection("users");
    var result = await _collection.findOne({
      'username': username,
    });
    return username;
  }
}