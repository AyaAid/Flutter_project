import 'package:flutter/material.dart';

import 'database/mongodb.dart';

import 'pages/PageSoiree.dart';
import 'pages/PageSoireeCreate.dart';
import 'pages/PageSoireeValidate.dart';

void main() async {

  await MongoDataBase.connect();

  runApp(MaterialApp(
    home: PageSoireeCreate(),
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
  ));
}