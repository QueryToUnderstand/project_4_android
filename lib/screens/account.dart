import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Account.dart';
import '../models/Cart.dart';
import 'orderDetail_screen.dart';

class AccountInfoScreen extends StatelessWidget {
  final Account account;


  AccountInfoScreen({required this.account});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin tài khoản'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Hình ảnh đại diện
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://vuoncayviet.com/data/aditems/93/vuon-cay-viet-banner-new.jpg'), // URL hình ảnh đại diện
              ),
            ),
            SizedBox(height: 20),
            // Thẻ thông tin tài khoản
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tên người dùng:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      account.name,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(cart: cart), // Truyền cart vào OrderDetailsScreen
                  ),
                );
              },
              child: Text('Xem danh sách đơn hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
