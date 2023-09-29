
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/main.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/pages/messagePage.dart';

class ViewUserPage extends StatelessWidget {
  ViewUserPage({super.key, required this.rtdb, required this.currentUsersName});
  final FirebaseDatabase rtdb;
  final String currentUsersName;

  // Widget contains another user that the current user can chat with,
  // When button is pressed it takes the current user to chat page
  Widget listItem({required Map user, required BuildContext context}){
    return Container(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context , MaterialPageRoute(builder: (context) => MessagePage(sendersName: currentUsersName, receiversName: user['username'], rtdb: rtdb,)));
        },
        child: Text(user['username'].toString(),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var dbRef = rtdb.ref('users');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Friends of $currentUsersName'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: FirebaseAnimatedList(
                    // Gets all other users from database to be displayed
                    // The current user can chat with any of them
                    query: dbRef,
                    padding: EdgeInsets.all(20),
                    itemBuilder: (context, snapshot, animation, index){
                      Map user = snapshot.value as Map;
                      // makes sure the current user isn´t displayed amongst other users.
                      if(user['username'].toString() != currentUsersName){
                        return listItem(user: user, context: context);
                      }else{
                        return SizedBox(width: 0,);
                      }
                    },
                  )
              )
            ]
        ),
      )
    );
  }
}


