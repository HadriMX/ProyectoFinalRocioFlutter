import 'package:flutter/material.dart';
import 'package:proyecto_final_rocio_flutter/src/bluetoothPage.dart';

import 'mainPage.dart';
import 'models/user.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<User> _users = [
    User(4, 'Javier Hernández'),
    User(3, 'Alejandro Gastélum'),
    User(2, 'Adolfo Ríos')
  ];

  User _selectedUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Iniciar sesión'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              top: 0.0,
              right: 8.0,
              bottom: 0.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButtonFormField(
                  value: _selectedUser,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                  ),
                  items: [
                    DropdownMenuItem(
                      child: Text(_users[0].name),
                      value: _users[0],
                    ),
                    DropdownMenuItem(
                      child: Text(_users[1].name),
                      value: _users[1],
                    ),
                    DropdownMenuItem(
                      child: Text(_users[2].name),
                      value: _users[2],
                    ),
                  ],
                  onChanged: (selected) {
                    setState(() {
                      _selectedUser = selected;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text('Iniciar sesión'),
                  onPressed: () {
                    if (_selectedUser == null) {
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          currentUser: _selectedUser,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
