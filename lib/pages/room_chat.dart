
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
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("iraq")
                  .document('najaf')
                  .collection('messages')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ));
                }

                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['text'];
                  final messageSender = message['sender'];
                  final userUid = message['uid'];
                  final messageWidget = MessageBubble(
                    messageText: messageText,
                    messageSender: messageSender,
                    isMe: userUid == widget.uid,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.pinkAccent.shade100, width: 2.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    if(messageController.text.isNotEmpty){
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
                    }
                    messageController.clear();
                  },
                  child: Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.pinkAccent.shade100,
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
              color: isMe ? Colors.pinkAccent.shade100 : Colors.white,
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
