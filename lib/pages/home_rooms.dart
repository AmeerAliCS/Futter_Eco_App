import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_app/components/rooms_list_tile.dart';
import 'package:eco_app/pages/home.dart';
import 'package:eco_app/pages/room_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time/time.dart';

class HomeRooms extends StatefulWidget {
  @override
  _HomeRoomsState createState() => _HomeRoomsState();
}

class _HomeRoomsState extends State<HomeRooms> {

  String name;
  TextEditingController _nameController = TextEditingController();
  bool nameValidate = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            RoomsListTile(
              title: 'العراق',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Iraq.svg/125px-Flag_of_Iraq.svg.png',
              joinNumber: 800,
              messageNumber: 10,
              onTap: (){
                _showDialog();
//                Navigator.push(context, MaterialPageRoute(builder: (context) => RoomChat()));
              },
            ),

            RoomsListTile(
              title: 'مصر',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Egypt.svg/125px-Flag_of_Egypt.svg.png',
              joinNumber: 300,
              messageNumber: 8,
              onTap: (){
                print('Tapped');
              },
            ),

            RoomsListTile(
              title: 'سوريا',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Flag_of_Syria.svg/125px-Flag_of_Syria.svg.png',
              joinNumber: 600,
              messageNumber: 11,
              onTap: (){
                print('Tapped');
              },
            ),

            RoomsListTile(
              title: 'السعودية',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/125px-Flag_of_Saudi_Arabia.svg.png',
              joinNumber: 760,
              messageNumber: 12,
              onTap: (){
                print('Tapped');
              },
            ),
          ],
        ),
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child:  AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content:  Row(
          children: <Widget>[
             Expanded(
              child:  Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration:  InputDecoration(
                      errorText: nameValidate ? null : 'يجب ان يكون الاسم بين 3 احرف الى 15 حرف',
                      labelText: 'ادخل اسمك',
                ),
                ),
              ))
          ],
        ),
        actions: <Widget>[
           FlatButton(
              child: Text('الغاء'),
              onPressed: () {
                Navigator.pop(context);
              }),
           FlatButton(
              child: Text('دخول'),
              onPressed: () {
                setState(() {
                  _nameController.text.length < 3 ||
                  _nameController.text.length > 15 ? nameValidate = false : nameValidate = true;

                  if(nameValidate){

                    FirebaseAuth.instance.signInAnonymously().then((user){
                      createUserInFirestore(user.user.uid);
                      createUserInsideRoom(user.user.uid);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RoomChat(
                        name: _nameController.text,
                        uid: user.user.uid,
                      )));
                    });

                  }
                });
              })
        ],
      ),
    );
  }

  createUserInFirestore(String uid) async {
    await usersRef.document(uid).setData({
      'Name' : _nameController.text,
      'Uid' : uid,
      'voiceRequest' : false,
      'micReqTime': DateTime.now()
    });
  }

  createUserInsideRoom(String uid) async {
    await Firestore.instance.collection('iraq').document('najaf').collection('users').document(uid).setData({
      'Name' : _nameController.text,
      'Uid' : uid,
      'voiceRequest' : false,
      'micReqTime': DateTime.now() - Duration(hours: 1),
    });
  }

}

