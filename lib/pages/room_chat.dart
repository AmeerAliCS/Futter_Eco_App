import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomChat extends StatefulWidget {
  RoomChat({@required this.name, @required this.uid});
  final String name;
  final String uid;

  @override
  _RoomChatState createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  String messageText;
  TextEditingController messageController = TextEditingController();
  final DateTime timestamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        title: Text('Room Chat'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("iraq")
                  .document('najaf')
                  .collection('messages')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                return !snapshot.hasData
                    ? Center(child: Text('انتظر رجاءا'))
                    : ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot message =
                              snapshot.data.documents[index];
                          bool _isSamePerson = message['uid'] == widget.uid;
                          return MessageBubble(
                              messageSender: message['sender'],
                              messageText: message['text'],
                              isMe: _isSamePerson,
//                              time: "12:00",
//                              delivered: false
                          );
                        },
                      );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Firestore.instance
                        .collection('iraq')
                        .document('najaf')
                        .collection('messages')
                        .document()
                        .setData({
                      'sender': widget.name,
                      'uid' : widget.uid,
                      'text': messageController.text,
                      'date': DateTime.now()
                    });
                    messageController.clear();
                  },
                  child: Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) {
                      messageText = value;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      hintText: 'اكتب رسالتك هنا...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageText, this.messageSender, this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(messageSender),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: Material(
              elevation: 5.0,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)),
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                child: Text(
                  messageText,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
