import 'dart:developer';
import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDataBase {
  static late Db _db;
  static late DbCollection _collection;

  static connect() async{
    _db = await Db.create(MONGO_URL);
    await _db.open();
    inspect(_db);
    _collection = _db.collection(COLLECTION_NAME);
  }
  Future<bool> verifyLog(String username, String password) async {
    if (_db == null || _collection == null) {
      throw Exception('La connexion à la base de données n\'a pas été établie.');
    }

    var result = await _collection.findOne({
      'username': username,
      'password': password,
    });
    return result != null;
  }
}