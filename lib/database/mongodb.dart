import 'dart:developer';
import 'dart:typed_data';
import '../form/profileFormPage.dart';
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

  Future<bool> checkUser(String username, String email, String collection) async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.findOne({
      'username': username,
      'email': email,
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
  Future<bool> addToDB(Map<String, dynamic> data, String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.insert(data);
    return result != null;
  }

  Future<List<Map<String, dynamic>>> getLast(String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.find(where.sortBy('_id', descending: true).limit(10));
    List<Map<String, dynamic>> last = [];
    await for (var data in result) {
      last.add(Map<String, dynamic>.from(data));
    }
    return last;
  }

  Future<List<Map<String, dynamic>>> getHorsesWithDP() async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection("horses");
    var result = await _collection.find(where.eq('isDP', 1));
    List<Map<String, dynamic>> last = [];
    await for (var data in result) {
      last.add(Map<String, dynamic>.from(data));
    }
    return last;
  }

  Future<List<Map<String, dynamic>>> get(String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.find(where.eq('isVerify', 1)).toList();
    return result;
  }

  Future<List<Map<String, dynamic>>> getAdmin(String collection) async {
    if (_db == null ) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.find(where.eq('isVerify', 0)).toList();
    return result;
  }

  Future<void> addEvent(String eventId, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.update(
        where.eq('_id', id),
        modify.set('isVerify', 1),
      );

    } else {
      print('Format d\'ID invalide : $eventId');
    }
  }


  Future<void> removeEvent(String eventId, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.remove(
        where.eq('_id', id),
      );

    } else {
      print('Format d\'ID invalide : $eventId');
    }
  }

  Future<bool> isVerifyEvent(String eventId, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.findOne(where.eq('_id', id).eq('isVerify', 0));

      return result != null;
    } else {
      print('Format d\'ID invalide : $eventId');
      return false;
    }
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

  Future<void> addParticipant(String eventId, String username, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.update(
        where.eq('_id', id),
        modify.push('participants', username),
      );

    } else {
      print('Format d\'ID invalide : $eventId');
    }
  }


  Future<void> removeParticipant(String eventId, String username, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.update(
        where.eq('_id', id),
        modify.pull('participants', username),
      );

    } else {
      print('Format d\'ID invalide : $eventId');
    }
  }

  Future<bool> isUserParticipatingInEvent(String eventId, String username, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.findOne(where.eq('_id', id).eq('participants', username));

      return result != null;
    } else {
      print('Format d\'ID invalide : $eventId');
      return false;
    }
  }
  Future<UserProfile?> getUserProfile(String username) async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection('users');
    var result = await _collection.findOne({'username': username});

    if (result != null) {
      return UserProfile(
        username: result['username'],
        fullName: result['fullName'] ?? '',
        email: result['email'] ?? '',
        phoneNumber: result['phoneNumber'] ?? '',
        link: result['linkedInProfile'] ?? '',
        dateOfBirth: result['dateOfBirth'] != null
            ? DateTime.parse(result['dateOfBirth'])
            : DateTime.now(),
      );
    } else {
      return null; // Utilisateur introuvable
    }
  }

  Future<bool> updateUserProfile(UserProfile user) async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection('users');
    var result = await _collection.update(
      where.eq('username', user.username),
      modify
          .set('fullName', user.fullName)
          .set('email', user.email)
          .set('phoneNumber', user.phoneNumber)
          .set('linkedInProfile', user.link)
          .set('dateOfBirth', user.dateOfBirth.toUtc().toIso8601String()),
    );

    return result != null;
  }

  Future<List<Map<String, dynamic>>> getEventsForUser(String username, String collection) async {
    if (_db == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }
    _collection = _db.collection(collection);
    var result = await _collection.find(where.eq('participants', username)).toList();
    return result;
  }

  Future<void> addComment(String eventId, String username, String comment, String collection) async {
    final idMatch = RegExp(r'ObjectId\("(\w+)"\)').firstMatch(eventId);
    if (idMatch != null) {
      final extractedId = idMatch.group(1);
      final id = ObjectId.parse(extractedId!);

      final _collection = _db.collection(collection);
      final result = await _collection.update(
        where.eq('_id', id),
        modify.push('comments', {'username': username, 'comment': comment}),
      );
    } else {
      print('Format d\'ID invalide : $eventId');
    }
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