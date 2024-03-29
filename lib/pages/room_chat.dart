import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_app/components/colors_icon.dart';
import 'package:eco_app/utils/settings.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:time/time.dart';
import 'package:timeago/timeago.dart' as timeago;

class RoomChat extends StatefulWidget {
  RoomChat(
      {@required this.name,
      @required this.uid,
      @required this.code,
      @required this.roomId,
      @required this.channelName,
      @required this.role});
  final String name;
  final String uid;
  final String roomId;
  final String code;
  final String channelName;
  final ClientRole role;

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
  final _infoStrings = <String>[];
  bool muted = false;
  String appBarTitle = 'Chat Room';
  static List<Color> _messageColors = [
    Colors.black,
    Colors.lightBlue,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.red
  ];
  ClientRole broadcaster = ClientRole.Broadcaster;

  List<AdminStruct> listOfAdmin = [];
  getAdmin() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('iraq')
        .document('najaf')
        .collection('roomAdmin')
        .getDocuments();

    snapshot.documents.forEach((val) {
      print(val.data['Uid']);
      listOfAdmin
          .add(AdminStruct(code: val.data['Code'], roomId: val.data['RoomID']));
    });

    for (int i = 0; i < listOfAdmin.length; i++) {
      if (widget.code == listOfAdmin[i].code &&
          widget.roomId == listOfAdmin[i].roomId) {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getAdmin();
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
//    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//    configuration.dimensions = Size(1920, 1080);
//    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
//    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//    await AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
      });
    };
  }

  Future<void> _sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Firestore.instance
          .collection('iraq')
          .document('najaf')
          .collection('users')
          .where('Uid', isEqualTo: widget.uid)
          .getDocuments()
          .then((value) {
        Firestore.instance
            .collection('iraq')
            .document('najaf')
            .collection('messages')
            .document()
            .setData({
          'sender': widget.name,
          'uid': widget.uid,
          'text': messageController.text,
          'textColor': value.documents.first['textColor'],
          'date': DateTime.now()
        });
        messageController.clear();
      });
    }
  }

  Widget horizontalDivider() {
    return Container(
      width: .5,
      height: 40,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pinkAccent.shade100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white70,
                size: 30,
              ),
              onPressed: () => {},
            ),
            horizontalDivider(),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble,
                    color: Colors.yellowAccent,
                    size: 30,
                  ),
                  onPressed: () => {},
                ),
              ],
            ),
            Expanded(
              child: Center(child: Text(appBarTitle)),
            )
          ],
        ),
        centerTitle: true,
        titleSpacing: 0,
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
          horizontalDivider(),
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
                    final String messageText = message['text'];
                    final String messageSender = message['sender'];
                    //final String date = "${message['date']}";
                    final String userUid = message['uid'];
                    final Timestamp timestamp = message['date'];
                    final Color textColor = _messageColors[message['textColor']];
                    final messageWidget = MessageBubble(
                        messageText: messageText,
                        messageSender: messageSender,
                        time: timestamp,
                        isMe: userUid == widget.uid,
                        color: textColor);
                    messageWidgets.add(messageWidget);
                  }

                  return Column(
                    children: [
                      Container(
                          child: Center(
                              child: IconButton(
                                  icon: Icon(Icons.mic),
                                  onPressed: () => {
                                        print('Hello')
                                      }) //Text("المفروض الرسالة الاولى"),
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
                    onPressed: _sendMessage,
                  ),
                  horizontalDivider(),
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
                  horizontalDivider(),
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
                  horizontalDivider(),
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
                final userUid = user['Uid'];
                final speakAllow = user['allowSpeak'];

                if (userUid == widget.uid) {
                  AgoraRtcEngine.setClientRole(speakAllow
                          ? ClientRole.Broadcaster
                          : ClientRole.Audience)
                      .then((value) => print('done'))
                      .catchError((onError) =>
                          print("Error In Allow Speker: " + onError));

                  // setState(() {
                  //   allowSpeaker = speakAllow;
                  // });
                }

                if (voiceRequest == true) {
                  micUsers.add(ListOfUsers(
                    name: name,
                    leading: leading,
                    voiceRequest: voiceRequest,
                    uid: userUid,
                    allowSpeak: speakAllow,
                    isAdmin: isAdmin,
                    changeAppBar: changeAppBar,
                  ));
                } else {
                  listUsers.add(ListOfUsers(
                    name: name,
                    leading: leading,
                    voiceRequest: voiceRequest,
                    isAdmin: isAdmin,
                    uid: userUid,
                    allowSpeak: speakAllow,
                    changeAppBar: changeAppBar,
                  ));
                }
              }

              return ListView(children: List.from(micUsers)..addAll(listUsers));
            },
          ),
        ),
      ),
    );
  }

  changeAppBar(String name){
    setState(() {
      appBarTitle = name;
    });
  }

  Future<void> _micFun() async {
    setState(() {
      voiceReqst = !voiceReqst;
    });
    if (voiceReqst) {
      Firestore.instance
          .collection('iraq')
          .document('najaf')
          .collection('users')
          .document(widget.uid)
          .updateData(
              {'voiceRequest': voiceReqst, 'micReqTime': DateTime.now()});
    } else {
      Firestore.instance
          .collection('iraq')
          .document('najaf')
          .collection('users')
          .document(widget.uid)
          .updateData({
        'voiceRequest': voiceReqst,
        'micReqTime': DateTime.now() - Duration(hours: 1),
      });
    }
  }
}

class ListOfUsers extends StatelessWidget {
  ListOfUsers(
      {this.name,
      this.voiceRequest,
      this.leading,
      this.isAdmin,
      this.uid,
      this.allowSpeak, this.changeAppBar});

  final String name;
  final String leading;
  final String uid;
  final bool allowSpeak;
  final bool voiceRequest;
  final bool isAdmin;
  final Function changeAppBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            isAdmin
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text('قائمة الادمن'),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text('كتم العضو'),
                            onPressed: () {
                              changeAppBar('Chat Room');
                              Firestore.instance
                                  .collection('iraq')
                                  .document('najaf')
                                  .collection('users')
                                  .document(uid)
                                  .updateData({'allowSpeak': false}).then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('الغاء الكتم'),
                            onPressed: () {
                              changeAppBar(name);
                              Firestore.instance
                                  .collection('iraq')
                                  .document('najaf')
                                  .collection('users')
                                  .document(uid)
                                  .updateData({'allowSpeak': true}).then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          SimpleDialogOption(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ColorsIcon(
                                  colour: Colors.red,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 5}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                ColorsIcon(
                                  colour: Colors.blue,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 4}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                ColorsIcon(
                                  colour: Colors.green,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 3}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                ColorsIcon(
                                  colour: Colors.yellow,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 2}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                ColorsIcon(
                                  colour: Colors.lightBlue,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 1}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                ColorsIcon(
                                  colour: Colors.black,
                                  onTap: () {
                                    Firestore.instance
                                        .collection('iraq')
                                        .document('najaf')
                                        .collection('users')
                                        .document(uid)
                                        .updateData({'textColor': 0}).then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    })
                : print('User Click');
          },
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ListTile(
              dense: true,
              title: Text(
                name,
                style: TextStyle(fontSize: 20),
              ),
              leading: Text(leading, textAlign: TextAlign.start),
              trailing: Text(voiceRequest ? '✋' : ''),
            ),
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
  MessageBubble({this.messageText, this.messageSender, this.time,this.isMe, this.color});

  final String messageText;
  final String messageSender;
  final Timestamp time;
  final bool isMe;
  final Color color;

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
                child: Text(timeago.format(time.toDate()) , overflow: TextOverflow.ellipsis),
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
                style: TextStyle(color: color, fontSize: 20.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminStruct {
  AdminStruct({this.roomId, this.code});
  String roomId;
  String code;
}
