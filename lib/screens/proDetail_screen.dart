import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Cart.dart';
import '../models/Product.dart';
import '../models/api.dart';


class ProDetailScreen extends StatelessWidget {
  final Product product;

  ProDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
              '${url.api}/images/${product.image}',
              width: double.infinity,
              height: 330,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 3),
            Text(
              product.name,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 5),
            Text(
              'Giá: ${product.price} VND',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              'Giá KM: ${product.sale_price} VND',
              style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            Text(
              'Trạng thái: ${product.status == 1 ? "Có sẵn" : "Không sẵn"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              'Mô tả sản phẩm:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              product.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã thêm sản phẩm vào giỏ hàng!')));
                Provider.of<CartModel>(context, listen: false)
                    .addProduct(product);
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}