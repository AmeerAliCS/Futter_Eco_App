import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:time/time.dart';

class RoomChat extends StatefulWidget {
  RoomChat({@required this.name, @required this.uid, @required this.code, @required this.roomId});
  final String name;
  final String uid;
  final String roomId;
  final String code;

  @override
  _RoomChatState createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  String messageText;
  TextEditingController messageController = TextEditingController();
  final DateTime timestamp = DateTime.now();
  bool isAdmin = false;

  bool _showEmoji = false;
  final FocusNode _textFocus = FocusNode();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool muteAudio = false;
  bool voiceReqst = false;


  List<AdminStruct> listOfAdmin = [];
  getAdmin() async {
    QuerySnapshot snapshot = await Firestore.instance.collection('iraq')
        .document('najaf').collection('roomAdmin').getDocuments();

    snapshot.documents.forEach((val){
      print(val.data['Uid']);
      listOfAdmin.add(AdminStruct(code: val.data['Code'], roomId: val.data['RoomID']));
    });

    for(int i = 0; i < listOfAdmin.length; i++){
      if(widget.code == listOfAdmin[i].code && widget.roomId == listOfAdmin[i].roomId){
        setState(() {
          isAdmin = true;
        });
      }
    }

//    setState(() {
//      followersCount = snapshot.documents.length;
//    });
  }

  @override
  void initState() {
    super.initState();
    getAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pinkAccent.shade100,
        title: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white70,
                  size: 30,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.chat_bubble,
                  color: Colors.yellowAccent,
                  size: 30,
                ),
                onPressed: () {}),
            SizedBox(
              width: 30.0,
            ),
            Text('Room Chat'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              muteAudio ? Icons.volume_off : Icons.volume_up,
              color: Colors.lightBlueAccent,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                muteAudio = !muteAudio;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.group,
              color: Colors.greenAccent,
              size: 30,
            ),
            onPressed: () => scaffoldKey.currentState.openEndDrawer(),
          ),
        ],
      ),
      body: Scaffold(
        key: scaffoldKey,
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
//                      Container(
//                          child: Center(
//                           child: Text("المفروض الرسالة الاولى"),
//                      )),
//                      Divider(),
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
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  Container(
                    width: .5,
                    height: 40,
                    color: Colors.grey,
                  ),
                  IconButton(
                    icon: Icon(
                        voiceReqst
                            ? Icons.settings_voice
                            : Icons.keyboard_voice,
                        color: Colors.greenAccent),
                    onPressed: _micFun,
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
        endDrawer: Drawer(
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("iraq")
                .document('najaf')
                .collection('users')
                .orderBy('micReqTime', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ));
              }
              final users = snapshot.data.documents;
              List<ListOfUsers> listUsers = [];
              List<ListOfUsers> micUsers = [];

              for (var user in users) {
                final name = user['Name'];
                final voiceRequest = user['voiceRequest'];
                final leading = user['leading'];

                if (voiceRequest == true) {
                  micUsers.add(ListOfUsers(
                    name: name,
                    leading: leading,
                    voiceRequest: voiceRequest,
                  ));
                } else {
                  listUsers.add(ListOfUsers(
                    name: name,
                    leading: leading,
                    voiceRequest: voiceRequest,
                    isAdmin: isAdmin,
                  ));
                }
              }
              return ListView(
                  children:
                  List.from(micUsers)..addAll(listUsers)
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _micFun() async {
    setState(() {
      voiceReqst = !voiceReqst;
    });
      if(voiceReqst){
        Firestore.instance.collection('iraq').document('najaf')
            .collection('users').document(widget.uid).updateData({
          'voiceRequest' : voiceReqst,
          'micReqTime' : DateTime.now()
        });
      }
      else{
        Firestore.instance.collection('iraq').document('najaf')
            .collection('users').document(widget.uid).updateData({
          'voiceRequest' : voiceReqst,
          'micReqTime' : DateTime.now() - Duration(hours: 1),
        });
      }

    }
}

class ListOfUsers extends StatelessWidget {
  ListOfUsers({this.name, this.voiceRequest, this.leading, this.isAdmin});
  final String name;
  final String leading;
  final bool voiceRequest;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            isAdmin ? print('Admin Click') : print('User Click');
          },
           child: ListTile(
            title: Text(
              name,
              style: TextStyle(fontSize: 20),
            ),
            leading: Text(leading),
            trailing: Text(voiceRequest ? '✋' : ''),
          ),
        ),
        Divider(
          color: Colors.black54,
        ),
      ],
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            color: Colors.black12,
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text("12:00AM"),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    '$messageSender',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text('😍'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: GestureDetector(
                onTap: () {
                  print('Tapped');
                },
                child: Text(
                  messageText,
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
    );
  }
}

class AdminStruct{
  AdminStruct({this.roomId, this.code});
  String roomId;
  String code;
}