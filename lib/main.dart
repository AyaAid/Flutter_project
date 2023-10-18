import 'package:andrestable/inscription.dart';
import 'package:flutter/material.dart';

import 'database/mongodb.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDataBase.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  NewAccount(),
      debugShowCheckedModeBanner: false,
    );
  }
}
