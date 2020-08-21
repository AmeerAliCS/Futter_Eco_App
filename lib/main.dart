import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eco_app/call.dart';
import 'package:eco_app/pages/home.dart';
import 'package:eco_app/pages/home_rooms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(localizationsDelegates: [
      // ... app-specific localization delegate[s] here
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ], supportedLocales: [
      const Locale('ar', 'AE')
    ], debugShowCheckedModeBanner: false, home: HomeRooms()));




class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Flutter QuickStart'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Channel name',
                    ),
                  ))
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(ClientRole.Broadcaster.toString()),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(ClientRole.Audience.toString()),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }
  Future<void> _handleCameraAndMic() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }
}
















//#-------------------------------------
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _isInChannel = false;
//   final _infoStrings = <String>[];

//   TextEditingController _controller = TextEditingController(text: "0");
// //  static final _sessions = List<VideoSession>();
//   String dropdownValue = 'Off';

//   final List<String> voices = [
//     'Off',
//     'Oldman',
//     'BabyBoy',
//     'BabyGirl',
//     'Zhubajie',
//     'Ethereal',
//     'Hulk'
//   ];

//   /// remote user list
//   final _remoteUsers = List<int>();

//   @override
//   void initState() {
//     super.initState();

//     _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Eco App'),
//         ),
//         body: Container(
//           child: Column(
//             children: [
//               Container(height: 320, child: _viewRows()),
//               TextField(
//                 controller: _controller,
//               ),
//               OutlineButton(
//                 child: Text(_isInChannel ? 'Leave Channel' : 'Join Channel',
//                     style: textStyle),
//                 onPressed: _toggleChannel,
//               ),
//               Row(
//                 children: <Widget>[
//                   MaterialButton(
//                       onPressed: audienceFuc, child: Text('Audience')),
//                   MaterialButton(
//                       onPressed: broadcasterFun, child: Text('Broadcaste'))
//                 ],
//               ),
//               Container(height: 100, child: _voiceDropdown()),
//               Expanded(child: Container(child: _buildInfoList())),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _voiceDropdown() {
//     return Scaffold(
//       body: Center(
//         child: DropdownButton<String>(
//           value: dropdownValue,
//           onChanged: (String newValue) {
//             setState(() {
//               dropdownValue = newValue;
//               VoiceChanger voice =
//                   VoiceChanger.values[(voices.indexOf(dropdownValue))];
//               AgoraRtcEngine.setLocalVoiceChanger(voice);
//             });
//           },
//           items: voices.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Future<void> _mute1() async {
//     int x = int.parse(_controller.text);

//     // List<AudioVolumeInfo> s = [AudioVolumeInfo(x, 250)];
//     // AgoraRtcEngine.onAudioVolumeIndication(250, s);
//     //VolumeIndicationHandler

//     AgoraRtcEngine.muteRemoteAudioStream(x, false);
//   }

//   Future<void> audienceFuc() async {
//     AgoraRtcEngine.setClientRole(ClientRole.Audience);
//   }

//   Future<void> broadcasterFun() async {
//     AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
//   }

//   Future<void> _initAgoraRtcEngine() async {
//     AgoraRtcEngine.create('2bd96b8c4aa74c648b5a4d225bbce8ba');

//     AgoraRtcEngine.enableAudio();
//     AgoraRtcEngine.setDefaultAudioRouteToSpeaker(true);
//     AgoraRtcEngine.setEnableSpeakerphone(true);
//     // AgoraRtcEngine.muteLocalAudioStream(true);

//     AgoraRtcEngine.isSpeakerphoneEnabled()
//         .then((value) => print('is Speaker: $value'));
// //    AgoraRtcEngine.enableSoundPositionIndication(true);
//     //  AgoraRtcEngine.setDefaultMuteAllRemoteAudioStreams(true);
// //    AgoraRtcEngine.muteRemoteAudioStream(987654321, false);

// //    AgoraRtcEngine.enableDualStreamMode(true);
// //    AgoraRtcEngine.enableLocalAudio(true);
// //    // AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
//     AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);
//     // AgoraRtcEngine.setClientRole(ClientRole.Audience);

// //
// //    VideoEncoderConfiguration config = VideoEncoderConfiguration();
// //    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
// //    AgoraRtcEngine.setVideoEncoderConfiguration(config);
//   }

//   void _addAgoraEventHandlers() {
//     AgoraRtcEngine.onJoinChannelSuccess =
//         (String channel, int uid, int elapsed) {
//       AgoraRtcEngine.setDefaultAudioRouteToSpeaker(true);
//       AgoraRtcEngine.setEnableSpeakerphone(true);

//       AgoraRtcEngine.isSpeakerphoneEnabled()
//           .then((value) => print('is Speaker: $value'));
//       setState(() {
//         String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
//         _infoStrings.add(info);
//       });
//     };

//     AgoraRtcEngine.onLeaveChannel = () {
//       setState(() {
//         _infoStrings.add('onLeaveChannel');
//         _remoteUsers.clear();
//       });
//     };

//     AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
//       setState(() {
//         String info = 'userJoined: ' + uid.toString();
//         _infoStrings.add(info);
//         _remoteUsers.add(uid);
//       });
//     };

//     AgoraRtcEngine.onUserOffline = (int uid, int reason) {
//       setState(() {
//         String info = 'userOffline: ' + uid.toString();
//         _infoStrings.add(info);
//         _remoteUsers.remove(uid);
//       });
//     };

//     AgoraRtcEngine.onFirstRemoteVideoFrame =
//         (int uid, int width, int height, int elapsed) {
//       setState(() {
//         String info = 'firstRemoteVideo: ' +
//             uid.toString() +
//             ' ' +
//             width.toString() +
//             'x' +
//             height.toString();
//         _infoStrings.add(info);
//       });
//     };
//   }

//   void _toggleChannel() {
//     setState(() async {
//       if (_isInChannel) {
//         _isInChannel = false;
//         await AgoraRtcEngine.leaveChannel();
//         await AgoraRtcEngine.stopPreview();
//       } else {
//         _isInChannel = true;
//         await AgoraRtcEngine.startPreview();
//         await AgoraRtcEngine.joinChannel(null, 'najaf', null, 0);
//       }
//     });
//   }

//   Widget _viewRows() {
//     return Row(
//       children: <Widget>[
//         for (final widget in _renderWidget)
//           Expanded(
//             child: Container(
//               child: widget,
//             ),
//           )
//       ],
//     );
//   }

//   Iterable<Widget> get _renderWidget sync* {
//     yield AgoraRenderWidget(0, local: true, preview: false);

//     for (final uid in _remoteUsers) {
//       yield AgoraRenderWidget(uid);
//     }
//   }

// //  VideoSession _getVideoSession(int uid) {
// //    return _sessions.firstWhere((session) {
// //      return session.uid == uid;
// //    });
// //  }
// //
// //  List<Widget> _getRenderViews() {
// //    return _sessions.map((session) => session.view).toList();
// //  }

//   static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

//   Widget _buildInfoList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemExtent: 24,
//       itemBuilder: (context, i) {
//         return ListTile(
//           title: Text(_infoStrings[i]),
//         );
//       },
//       itemCount: _infoStrings.length,
//     );
//   }
// }
