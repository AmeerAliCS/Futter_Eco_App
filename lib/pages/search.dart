import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Stack(
          children: [
            TextFormField(
              textAlign: TextAlign.center,
              decoration:
                  InputDecoration(hintText: 'ادخل اسم الغرفة او رقم الغرفة'),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20),
                  Icon(Icons.group),
                  SizedBox(width: 10),
                  Text('202'),
                  SizedBox(width: 30),
                  Icon(Icons.message),
                  SizedBox(width: 10),
                  Text('112'),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
