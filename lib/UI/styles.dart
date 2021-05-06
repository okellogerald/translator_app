import 'package:flutter/material.dart';

class MyColors {
  final Color main = Color(0xff4284F4),
      white = Colors.white.withOpacity(.85),
      black = Colors.black87,
      inactive = Colors.black26,
      background = Colors.grey.withOpacity(.05);
}

class MyTextstyles {
  Color color = Colors.black,bgColor=Colors.transparent;
  double size = 20;

  TextStyle medium({color, size,bgColor}) {
    return TextStyle(fontFamily: 'Medium', fontSize: size, color: color,backgroundColor: bgColor);
  }

  TextStyle light({color, size,bgColor}) {
    return TextStyle(fontFamily: 'light', fontSize: size, color: color);
  }

  TextStyle regular({color, size,bgColor}) {
    return TextStyle(fontFamily: 'Regular', fontSize: size, color: color);
  }
}
