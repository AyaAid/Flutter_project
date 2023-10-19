
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PageSoireeVerify extends StatefulWidget {
  @override
  _PageSoireeVerifyState createState() => _PageSoireeVerifyState();
}

class _PageSoireeVerifyState extends State<PageSoireeVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En attente de validation'),
      ),
      body: Center(
        child: Text('Votre demande de création de soirée a été envoyée aux gestionnaires.'),
      ),
    );
  }
}
