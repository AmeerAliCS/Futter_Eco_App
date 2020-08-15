import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_app/pages/favorite.dart';
import 'package:eco_app/pages/home_rooms.dart';
import 'package:eco_app/pages/more_screen.dart';
import 'package:eco_app/pages/search.dart';
import 'package:flutter/material.dart';

final usersRef = Firestore.instance.collection('users');

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var pageController = PageController();
  int pageIndex = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        title: Text('ECO APP'),
        centerTitle: true,
      ),
      body: PageView(
        children: [
          HomeRooms(),
          Favorite(),
          Search(),
          MoreScreen(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),

     bottomNavigationBar: BottomNavyBar(
       iconSize: 30.0,
       mainAxisAlignment: MainAxisAlignment.spaceAround,
       backgroundColor: Colors.white,
       selectedIndex: pageIndex,
       onItemSelected: onTap,

       items: <BottomNavyBarItem>[


         BottomNavyBarItem(
             activeColor: Colors.pinkAccent.shade100,
             inactiveColor: Colors.black45,
             title: Text('الغرف'),
             icon: Icon(Icons.home,)
         ),

         BottomNavyBarItem(
             activeColor: Colors.pinkAccent.shade100,
             inactiveColor: Colors.black45,
             title: Text('المفضلة'),
             icon: Icon(Icons.favorite,)
         ),


         BottomNavyBarItem(
             activeColor: Colors.pinkAccent.shade100,
             inactiveColor: Colors.black45,
             title: Text('بحث'),
             icon: Icon(Icons.search,)
         ),

         BottomNavyBarItem(
             activeColor: Colors.pinkAccent.shade100,
             inactiveColor: Colors.black45,
             title: Text('المزيد'),
             icon: Icon(Icons.more_horiz,)
         ),

       ],
     ),

    );
  }


  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut
    );
  }

}
