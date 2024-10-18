import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/category_screen.dart';
import 'package:tree/screens/homePage_screen.dart';
import 'package:tree/screens/login_screen.dart';
import 'package:tree/screens/product_screen.dart';

import 'models/Cart.dart';

void main() {
  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CartModel()),
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NguyenThanhTrung',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}