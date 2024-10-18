import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Cart.dart';
import '../models/api.dart';
import 'login_screen.dart';
import 'orderDetail_screen.dart';

class CartScreen extends StatelessWidget {
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("fullName") != null;
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('Giỏ hàng đang trống!'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    '${url.api}/images/${cart.items[index].product.image}',
                    fit: BoxFit.cover,
                  ),
                  title: Text(cart.items[index].product.name),
                  subtitle: Text('Số lượng: ${cart.items[index].quantity}'),
                  trailing: IconButton(
                    icon: Icon(Icons.highlight_remove),
                    onPressed: () {
                      cart.removeProduct(cart.items[index].product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng!')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tổng tiền: ${cart.totalPrice} VND',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                bool loggedIn = await isLoggedIn();
                if (!loggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } else {
                  // Lưu trữ sản phẩm đã đặt hàng và xóa giỏ hàng
                  cart.placeOrder();

                  // Chuyển đến màn hình chi tiết đơn hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(cart: cart),
                    ),
                  );

                  // Hiển thị thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đặt hàng thành công!')),
                  );
                }
              },
              child: Text('Đặt hàng'),
            ),
          ),
        ],
      ),
    );
  }
}
