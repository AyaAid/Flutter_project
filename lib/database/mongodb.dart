import 'dart:developer';
import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

const COLLECTION_PARTYS = "partys";

class MongoDataBase {
  static connect() async{
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    var collections = db.collection(COLLECTION_NAME);
  }

  static Future<void> insertData(Map<String, dynamic> data) async {
    final db = Db(MONGO_URL);
    await db.open();

    final collection = db.collection(COLLECTION_PARTYS);
    await collection.insert(data);

    await db.close();
  }
}