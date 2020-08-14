import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              FlatButton(
                child: Text("الاعدادات", style: TextStyle(fontSize: 18)),
                onPressed: () => {},
              ),
              Padding(padding: EdgeInsets.only(left: 50, right: 50),
              child: Divider(height: 10, color: Colors.blueGrey)),


              FlatButton(
                child: Text("غرف المبيعات", style: TextStyle(fontSize: 18)),
                onPressed: () => {},
              ),
              Padding(padding: EdgeInsets.only(left: 50, right: 50),
                  child: Divider(height: 10, color: Colors.blueGrey)),


              FlatButton(
                child: Text("شراء خدمة", style: TextStyle(fontSize: 18)),
                onPressed: () => {},
              ),
              Padding(padding: EdgeInsets.only(left: 50, right: 50),
                  child: Divider(height: 10, color: Colors.blueGrey)),


              FlatButton(
                child: Text("أعادة تحميل القائمة", style: TextStyle(fontSize: 18)),
                onPressed: () => {},
              ),
              Padding(padding: EdgeInsets.only(left: 50, right: 50),
                  child: Divider(height: 10, color: Colors.blueGrey)),


              FlatButton(
                child: Text("عن البرنامج", style: TextStyle(fontSize: 18)),
                onPressed: () => {},
              ),


            ],
          )
        ),
      ),
    );
  }
}
