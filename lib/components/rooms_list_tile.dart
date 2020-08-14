import 'package:flutter/material.dart';

class RoomsListTile extends StatelessWidget {
  RoomsListTile(
      {this.title, this.imageUrl, this.joinNumber, this.messageNumber});

  final String title;
  final String imageUrl;
  final int joinNumber;
  final int messageNumber;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading:
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
      subtitle: Row(
        children: <Widget>[
          SizedBox(width: 20),
          Icon(Icons.group),
          SizedBox(width: 10),
          Text(joinNumber.toString()),
          SizedBox(width: 30),
          Icon(Icons.message),
          SizedBox(width: 10),
          Text(messageNumber.toString()),
        ],
      ),
    );
  }
}
