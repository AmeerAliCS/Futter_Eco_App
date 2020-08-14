import 'package:eco_app/components/rooms_list_tile.dart';
import 'package:flutter/material.dart';

class HomeRooms extends StatefulWidget {
  @override
  _HomeRoomsState createState() => _HomeRoomsState();
}

class _HomeRoomsState extends State<HomeRooms> {
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
            ),

            RoomsListTile(
              title: 'مصر',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Egypt.svg/125px-Flag_of_Egypt.svg.png',
              joinNumber: 300,
              messageNumber: 8,
            ),

            RoomsListTile(
              title: 'سوريا',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Flag_of_Syria.svg/125px-Flag_of_Syria.svg.png',
              joinNumber: 600,
              messageNumber: 11,
            ),


            RoomsListTile(
              title: 'السعودية',
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/125px-Flag_of_Saudi_Arabia.svg.png',
              joinNumber: 760,
              messageNumber: 12,
            ),
          ],
        ),
      ),
    );
  }
}
