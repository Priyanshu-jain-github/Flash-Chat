import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:FlashChat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:FlashChat/components/messageStream.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedinuser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagetextcontroller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String message;
  @override
  void initState() {
    super.initState();
    getcurrentuser();
  }

  void getcurrentuser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedinuser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextcontroller,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                      ),
                      onChanged: (value) {
                        message = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagetextcontroller.clear();
                      _firestore.collection('messages').add(
                        {
                          'Text': message,
                          'Sender': loggedinuser.email,
                        },
                      );
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageStream extends StatelessWidget {




//  void getcurrentuser() async {
//    try {
//      final user = await _auth.currentUser();
//      if (user != null) {
//        loggedinuser = user;
//      }
//    } catch (e) {
//      print(e);
//    }
//  }

  @override
  Widget build(BuildContext context) {
//    getcurrentuser();
    return StreamBuilder(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messagebubbles = [];
        for (var message in messages) {
          final messagetext = message.data['Text'];
          final messagesender = message.data['Sender'];
          final currentuser = loggedinuser.email;

          final messagewidget = MessageBubble(
            sender: messagesender,
            text: messagetext,
            isMe: currentuser == messagesender,
          );
          messagebubbles.add(messagewidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.all(8.0),
            children: messagebubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe});
  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sender,
              style: TextStyle(fontSize: 10.0, color: Colors.black54),
            ),
            Material(
              elevation: 6.0,
              borderRadius: isMe? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ):BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              color: isMe ? Colors.blueGrey[800] : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 15.0),
                child: Text(
                  text,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.blueGrey[800],
                      fontSize: 15.0),
                ),
              ),
            ),
          ],
        ));
  }
}
