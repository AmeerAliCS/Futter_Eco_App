import 'package:flutter/material.dart';

class ColorsIcon extends StatelessWidget {

  ColorsIcon({this.colour, this.onTap});
  final Color colour;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 30.0,
        width: 30.0,
        color: colour,
      ),

      onTap: onTap,
    );
  }
}
