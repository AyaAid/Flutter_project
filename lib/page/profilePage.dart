import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ffeLinkController = TextEditingController();

  String name = 'John Doe';
  String email = 'johndoe@example.com';
  String age = '30';
  String phone = '+1234567890';
  String ffeLink = 'https://example.com';

  @override
  void initState() {
    super.initState();
    nameController.text = name;
    emailController.text = email;
    ageController.text = age;
    phoneController.text = phone;
    ffeLinkController.text = ffeLink;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    phoneController.dispose();
    ffeLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        backgroundColor: Colors.blue, 
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/profile_image.jpg'),
              ),
              SizedBox(height: 20),
              isEditing
                  ? _buildTextField(nameController, 'Nom Complet', FontWeight.bold, Icons.person)
                  : _buildText(name, 24, Colors.black),
              isEditing
                  ? _buildTextField(emailController, 'Adresse Email', FontWeight.normal, Icons.email)
                  : _buildText(email, 18, Colors.black54),
              SizedBox(height: 20),
              isEditing
                  ? _buildTextField(ageController, 'Âge', FontWeight.normal, Icons.access_time)
                  : _buildText(age, 18, Colors.black54),
              isEditing
                  ? _buildTextField(phoneController, 'Numéro de Téléphone', FontWeight.normal, Icons.phone)
                  : _buildText(phone, 18, Colors.black54),
              isEditing
                  ? _buildTextField(ffeLinkController, 'Lien vers le compte FFE', FontWeight.normal, Icons.link)
                  : _buildText(ffeLink, 18, Colors.blue, true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      
                      name = nameController.text;
                      email = emailController.text;
                      age = ageController.text;
                      phone = phoneController.text;
                      ffeLink = ffeLinkController.text;
                    }
                    isEditing = !isEditing;
                  });
                },
                child: Text(isEditing ? 'Enregistrer' : 'Éditer le Profil'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, 
                  textStyle: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize, [Color? color, bool underline = false]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        decoration: underline ? TextDecoration.underline : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, FontWeight fontWeight, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 18, fontWeight: fontWeight),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
