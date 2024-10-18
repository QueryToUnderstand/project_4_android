import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api.dart';
import '../models/Cart.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CartModel cart;

  OrderDetailsScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đơn hàng'),
      ),
      body: cart.orderedItems.isEmpty
          ? Center(child: Text('Không có sản phẩm nào trong đơn hàng!'))
          : ListView.builder(
        itemCount: cart.orderedItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              '${url.api}/images/${cart.orderedItems[index].product.image}',
              fit: BoxFit.cover,
            ),
            title: Text(cart.orderedItems[index].product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số lượng: ${cart.orderedItems[index].quantity}'),
                Text('Giá: ${cart.orderedItems[index].product.sale_price} VND'), // Hiển thị giá tiền
              ],
            ),

          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Thanh toán: ${cart.orderedTotalPrice} VND',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
