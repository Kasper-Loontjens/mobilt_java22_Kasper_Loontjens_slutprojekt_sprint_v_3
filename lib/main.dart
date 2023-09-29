import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/components/my_text_field.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/pages/messagePage.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/pages/viewUsers.dart';

import 'firebase_options.dart';

Future<void> main() async {

  // Creates connection to Realtime Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firebaseApp = Firebase.app();
  final FirebaseDatabase rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://kotlinprojektgrit-default-rtdb.europe-west1.firebasedatabase.app/');

  runApp(MyApp(rtdb: rtdb));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.rtdb});
  final FirebaseDatabase rtdb;

  // Holds the navigator, making it easy to switch pages
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        pages: [MaterialPage(child: LoginPage(rtdb: rtdb,)),],
        onPopPage: (route, result){
          return route.didPop(result);
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {

  const LoginPage({super.key, required this.rtdb});
  final FirebaseDatabase rtdb;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passWordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var dbRef = widget.rtdb.ref('users');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text("Login "),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // for writing username and password to login
              MyTextField(controller: userNameController, hintText: "Username | Tip: bob/rob", obscureText: false),
              MyTextField(controller: passWordController, hintText: "Password | Tip: bob/rob", obscureText: true),

              ElevatedButton(onPressed: () async {
                // creates new snapshot from database connection
                var snapshot = await dbRef.get();
                // if snapshot isn´t empty
                if (snapshot.exists) {
                  // Loops through the users in database, if user wrote correct password and username in text-fields it will log in to a page where all other users are shown
                  Map users = snapshot.value as Map;
                  users.forEach((key, value) {
                    if(value['username'].toString() == userNameController.text.toString()
                    && value['password'].toString() == passWordController.text.toString()){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewUserPage(rtdb: widget.rtdb, currentUsersName: value['username'].toString(),)));
                    }
                  });
                } else {
                  print('No data available.');
                }

              },
                child: Text("Login"),
              )
            ],
          ),
        ),
      )
    );
  }
}
