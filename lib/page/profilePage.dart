import 'package:flutter/material.dart';
import '../database/mongodb.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
final _formKey = GlobalKey<FormState>();

  String name = 'John Doe';
  String email = 'johndoe@example.com';
  String dateOfBirth = '30';
  String phone = '+1234567890';
  String ffeLink = 'https://example.com';

  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: isEditing ? _buildEditProfileForm() : _buildProfileData(),
        ),
      ),
    );
  }

  Widget _buildProfileData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 80,
          backgroundImage: AssetImage('assets/profile_image.jpg'),
        ),
        SizedBox(height: 20),
        _buildInfoCard('Nom Complet', name, Icons.person),
        _buildInfoCard('Adresse Email', email, Icons.email),
        _buildInfoCard('Âge', dateOfBirth, Icons.access_time),
        _buildInfoCard('Numéro de Téléphone', phone, Icons.phone),
        _buildInfoCard('Lien vers le compte FFE', ffeLink, Icons.link),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard(String label, String text, IconData icon) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(text, style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/profile_image.jpg'),
            ),
            SizedBox(height: 20),
            _buildTextFormField('Nom Complet', name, Icons.person),
            _buildTextFormField('Adresse Email', email, Icons.email),
            _buildTextFormField('Âge', dateOfBirth, Icons.access_time),
            _buildTextFormField('Numéro de Téléphone', phone, Icons.phone),
            _buildTextFormField('Lien vers le compte FFE', ffeLink, Icons.link),
            SizedBox(height: 20),
     ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedData = {
        'name': name, 
        'age': dateOfBirth,   
        'email': email,
        'phone': phone,
        'ffeLink': ffeLink,
      };

      final success = await MongoDataBase().updateProfileInfo(updatedData);

      if (success) {
        setState(() {
          isEditing = false;
        });
      } else {
    
      }
    }
  },
  child: Text('Enregistrer'),
  style: ElevatedButton.styleFrom(
    primary: Colors.blue,
    textStyle: TextStyle(
      fontSize: 16,
    ),
  ),
)         
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String labelText, String initialValue, IconData icon) {
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer une valeur';
        }
        return null;
      },
      onSaved: (value) {
      },
    );
  }
}
