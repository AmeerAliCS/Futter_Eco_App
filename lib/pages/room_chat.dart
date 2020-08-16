import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  bool _showEmoji = false;
  final FocusNode _textFocus = FocusNode();


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

                return Column(
                  children: [
                    Container(
                        child: Center(
                              child: Text(
                                  "المفروض الرسالة الاولى"),
                        )),
                    Divider(),
                    Expanded(
                      child: ListView(
                        reverse: true,
                        children: messageWidgets,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: Colors.pinkAccent.shade100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_upward,
                      color: Colors.greenAccent, size: 30.0),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      Firestore.instance
                          .collection('iraq')
                          .document('najaf')
                          .collection('messages')
                          .document()
                          .setData({
                        'sender': widget.name,
                        'uid': widget.uid,
                        'text': messageController.text,
                        'date': DateTime.now()
                      });
                    }
                    messageController.clear();
                  },
                ),
                Container(
                  width: .5,
                  height: 40,
                  color: Colors.grey,
                ),
                IconButton(
                  icon: _showEmoji
                      ? Icon(Icons.keyboard)
                      : Icon(
                          Icons.tag_faces,
                          color: Colors.amberAccent,
                        ),
                  onPressed: () {
                    if (_showEmoji == false) {
                      _textFocus.unfocus();
//                      FocusManager.instance.primaryFocus.unfocus(); //hid Keyboard
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    } else {
                      _textFocus.requestFocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    }
                  },
                ),
                Container(
                  width: .5,
                  height: 40,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: TextField(
                      focusNode: _textFocus,
                      onTap: () => setState(() {
                        _showEmoji = false;
                      }),
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintText: 'اكتب رسالتك هنا...',
                        border: InputBorder.none
                      ),
                    ),
                  ),
                ),
                Container(
                  width: .5,
                  height: 40,
                  color: Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.settings_voice, color: Colors.greenAccent),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _showEmoji
              ? EmojiPicker(
                  rows: 4,
                  columns: 8,
                  buttonMode: ButtonMode.CUPERTINO,
                  numRecommended: 10,
                  onEmojiSelected: (emoji, category) {
                    messageController.text += emoji.emoji;
                  },
                )
              : SizedBox(),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 30.0,
            color: Colors.black12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    messageSender,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                messageText,
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
