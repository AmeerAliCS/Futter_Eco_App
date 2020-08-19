import 'package:flutter/material.dart';

class RoomsListTile extends StatelessWidget {
  RoomsListTile(
      {@required this.title,
      @required this.imageUrl,
      @required this.joinNumber,
      @required this.messageNumber,
      @required this.onTap,
      @required this.longTap});

  final String title;
  final String imageUrl;
  final int joinNumber;
  final int messageNumber;
  final Function onTap;
  final Function longTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: onTap,
       onLongPress: longTap,
       child: ListTile(
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
      ),
    );
  }
}
