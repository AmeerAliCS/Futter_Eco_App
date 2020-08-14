import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInChannel = false;
  final _infoStrings = <String>[];

  TextEditingController _controller = TextEditingController(text: "0");
  static final _sessions = List<VideoSession>();
  String dropdownValue = 'Off';

  final List<String> voices = [
    'Off',
    'Oldman',
    'BabyBoy',
    'BabyGirl',
    'Zhubajie',
    'Ethereal',
    'Hulk'
  ];

  /// remote user list
  final _remoteUsers = List<int>();

  @override
  void initState() {
    super.initState();

    _initAgoraRtcEngine();
    _addAgoraEventHandlers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora Flutter SDK'),
        ),
        body: Container(
          child: Column(
            children: [
              Container(height: 320, child: _viewRows()),
              TextField(
                controller: _controller,
              ),
              OutlineButton(
                child: Text(_isInChannel ? 'Leave Channel' : 'Join Channel',
                    style: textStyle),
                onPressed: _toggleChannel,
              ),
              MaterialButton(onPressed: _mute1),
              Container(height: 100, child: _voiceDropdown()),
              Expanded(child: Container(child: _buildInfoList())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceDropdown() {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
              VoiceChanger voice =
              VoiceChanger.values[(voices.indexOf(dropdownValue))];
              AgoraRtcEngine.setLocalVoiceChanger(voice);
            });
          },
          items: voices.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }


  Future<void> _mute1() async {
    int x = int.parse(_controller.text) * -1;
    AgoraRtcEngine.muteRemoteAudioStream(x, false);
  }

  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create('2bd96b8c4aa74c648b5a4d225bbce8ba');

    AgoraRtcEngine.enableAudio();
    AgoraRtcEngine.setEnableSpeakerphone(true);

//    AgoraRtcEngine.enableSoundPositionIndication(true);
    AgoraRtcEngine.setDefaultMuteAllRemoteAudioStreams(true);
//    AgoraRtcEngine.muteRemoteAudioStream(987654321, false);


//    AgoraRtcEngine.enableDualStreamMode(true);
//    AgoraRtcEngine.enableLocalAudio(true);
//    // AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);
//
//    VideoEncoderConfiguration config = VideoEncoderConfiguration();
//    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
//    AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _remoteUsers.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        String info = 'userJoined: ' + uid.toString();
        _infoStrings.add(info);
        _remoteUsers.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        String info = 'userOffline: ' + uid.toString();
        _infoStrings.add(info);
        _remoteUsers.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {
      setState(() {
        String info = 'firstRemoteVideo: ' +
            uid.toString() +
            ' ' +
            width.toString() +
            'x' +
            height.toString();
        _infoStrings.add(info);
      });
    };
  }

  void _toggleChannel() {
    setState(() async {
      if (_isInChannel) {
        _isInChannel = false;
        await AgoraRtcEngine.leaveChannel();
        await AgoraRtcEngine.stopPreview();
      } else {
        _isInChannel = true;
        await AgoraRtcEngine.startPreview();
        await AgoraRtcEngine.joinChannel(null, 'flutter', null, 0);
      }
    });
  }

  Widget _viewRows() {
    return Row(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          )
      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    yield AgoraRenderWidget(0, local: true, preview: false);

    for (final uid in _remoteUsers) {
      yield AgoraRenderWidget(uid);
    }
  }

  VideoSession _getVideoSession(int uid) {
    return _sessions.firstWhere((session) {
      return session.uid == uid;
    });
  }

  List<Widget> _getRenderViews() {
    return _sessions.map((session) => session.view).toList();
  }

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  Widget _buildInfoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemExtent: 24,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(_infoStrings[i]),
        );
      },
      itemCount: _infoStrings.length,
    );
  }
}

class VideoSession {
  int uid;
  Widget view;
  int viewId;

  VideoSession(int uid, Widget view) {
    this.uid = uid;
    this.view = view;
  }
}














/// p ------------------------------------------------------------ ///
//void main() {
//  runApp(MyApp());
//}
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Flutter Demo',
//      home: MyHomePage(),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("ECO APP"),
//        centerTitle: true,
//        backgroundColor: Colors.pinkAccent.shade100,
//      ),
//      body: Center(
//        child: ListView(
//          children: <Widget>[
//            ListTile(
//              leading: CircleAvatar(
//            radius: 30,
//            backgroundImage: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Iraq.svg/125px-Flag_of_Iraq.svg.png")
//        ),
//              title: Text("العراق"),
//              subtitle:
//                   Row(
//                children: <Widget>[
//                  SizedBox(width: 20),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.group),
//                      SizedBox(width: 10),
//                      Text("800"),
//
//
//                    ],
//                  ),
//                  SizedBox(width: 30),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.message),
//                      SizedBox(width: 10),
//                      Text("10"),
//
//
//                    ],
//                  ),
//
//                ],
//              ),
//            ),
//
//
//            ListTile(
//              leading: CircleAvatar(
//                  radius: 30,
//                  backgroundImage: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Egypt.svg/125px-Flag_of_Egypt.svg.png")
//              ),
//              title: Text("مصر"),
//              subtitle:
//              Row(
//                children: <Widget>[
//                  SizedBox(width: 20),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.group),
//                      SizedBox(width: 10),
//                      Text("300"),
//
//
//                    ],
//                  ),
//                  SizedBox(width: 30),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.message),
//                      SizedBox(width: 10),
//                      Text("8"),
//
//
//                    ],
//                  ),
//
//                ],
//              ),
//            ),
//
//
//
//            ListTile(
//              leading: CircleAvatar(
//                  radius: 30,
//                  backgroundImage: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Flag_of_Syria.svg/125px-Flag_of_Syria.svg.png")
//              ),
//              title: Text("سوريا"),
//              subtitle:
//              Row(
//                children: <Widget>[
//                  SizedBox(width: 20),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.group),
//                      SizedBox(width: 10),
//                      Text("600"),
//
//
//                    ],
//                  ),
//                  SizedBox(width: 30),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.message),
//                      SizedBox(width: 10),
//                      Text("11"),
//
//
//                    ],
//                  ),
//
//                ],
//              ),
//            ),
//
//
//            ListTile(
//              leading: CircleAvatar(
//                  radius: 30,
//                  backgroundImage: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/125px-Flag_of_Saudi_Arabia.svg.png")
//              ),
//              title: Text("السعودية"),
//              subtitle:
//              Row(
//                children: <Widget>[
//                  SizedBox(width: 20),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.group),
//                      SizedBox(width: 10),
//                      Text("760"),
//
//
//                    ],
//                  ),
//                  SizedBox(width: 30),
//                  Row(
//                    children: <Widget>[
//                      Icon(Icons.message),
//                      SizedBox(width: 10),
//                      Text("12"),
//
//
//                    ],
//                  ),
//
//                ],
//              ),
//            ),
//
//          ],
//        ),
//      ),
//      bottomNavigationBar: BottomNavigationBar(
//        backgroundColor: Colors.pinkAccent.shade100,
//        items: const <BottomNavigationBarItem>[
//          BottomNavigationBarItem(
//            icon: Icon(Icons.home),
//            title: Text('الغرف'),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.favorite),
//            title: Text('المفضلة'),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.search),
//            title: Text('بحث'),
//          ),
//        ],
//        currentIndex: 0,
//        selectedItemColor: Colors.white,
//        onTap: (d) => {},
//      ),
//    );
//  }
//}
