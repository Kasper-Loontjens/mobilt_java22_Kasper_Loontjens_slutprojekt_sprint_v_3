import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobilt_java22_kasper_loontjens_slutprojekt_sprint_v_3/main.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.sendersName, required this.receiversName, required this.rtdb});
  final String sendersName;
  final String receiversName;
  final FirebaseDatabase rtdb;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    ChatBrain chatBrain = ChatBrain();
    String receiverName = widget.receiversName;

    final messageBarController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text("Message $receiverName"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                // Gets the messages as a list and displays them by date.
                  child: FutureBuilder(
                    future: chatBrain.getMessages(widget.rtdb, receiverName, widget.sendersName),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index){
                              return messageWidge(snapshot.data![index]);
                            });
                      }else if(snapshot.hasError){
                        return Text("empty");
                      }else{
                        return Text("loading");
                      }

                    },
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: messageBarController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[400],
                        filled: true,
                      ),
                      ),
                  ),
                  ElevatedButton(
                    // when button is pressed sends message to database. Reads message from text-field.
                      onPressed: (){
                        if(messageBarController.text.isNotEmpty){
                          chatBrain.sendMessage(
                              widget.rtdb,
                              widget.sendersName,
                              widget.receiversName,
                              messageBarController.text);
                          messageBarController.clear();
                          setState(() {});
                        }
                      },
                      child: Text("Send")
                  ),
                ]
              ),

            ],
          ),
        ),

      ),
    );

  }
  Widget messageWidge(Map message){

    // Widget displays the message, alignment based on if the message came from current user or receiver.
    var alignment = (message['receiver'].toString() == widget.receiversName)? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [

          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.pink
            ),
            child: Text(message['message'],
              style: TextStyle(fontSize: 16),),
          )
        ],
      )
    );
  }
}

class ChatBrain extends ChangeNotifier{

  // Gets all the messages from database, sorts into list.
  Future<List<Map>> getMessages(FirebaseDatabase rtdb, String receiverName, String senderName) async {
    // Creates snapshot and list
    var dbRef = rtdb.ref('messages');
    final snapshot = await dbRef.get();
    List<Map> li = [];
    if (snapshot.exists) {
      // loops through the messages and adds the messages to the list
      // if current user and current receiver is named in message object.
      Map val = snapshot.value as Map;
      val.forEach((key, value) {
        if(value['receiver'].toString() == receiverName && value['sender'].toString() == senderName
            || value['sender'].toString() == receiverName && value['receiver'].toString() == senderName){
          li.add(value);
        }
      });
      // Sort by date
      li.sort((a,b) {
        var adate = b['sentTime'];//before -> var adate = a.expiry;
        var bdate = a['sentTime']; //var bdate = b.expiry;
        return -adate.compareTo(bdate);
      });
      return li;
    } else {
      print('No data available.');
      throw Exception("No data available");
    }
  }

  // Method to send message
  Future<void> sendMessage(FirebaseDatabase rtdb, String sender, String receiver, String message) async {
    var dbRef = rtdb.ref('messages');
    var sentTime = DateTime.timestamp();
    // Push to create unique key.
    await dbRef.push().set({
      'sender': sender,
      'receiver': receiver,
      'sentTime': sentTime.toString(),
      'message': message
   });
  }
}
