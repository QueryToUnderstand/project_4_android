import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/proDetail_screen.dart';
import '../models/Cart.dart';
import '../models/Product.dart';
import '../models/api.dart';
import 'package:http/http.dart' as http;

class SearchResultsScreen extends StatefulWidget {
  final String query;

  SearchResultsScreen({required this.query});

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Product> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchProducts(widget.query);
  }

  Future<void> searchProducts(String query) async {
    final response = await http.get(Uri.parse('${url.api}/api/search-product?key=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        results = (data['result'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Không thể tìm sản phẩm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả tìm kiếm: "${widget.query}"'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? Center(child: Text('Không tìm thấy sản phẩm nào!'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số cột trong GridView
          crossAxisSpacing: 8.0, // Khoảng cách ngang giữa các phần tử
          mainAxisSpacing: 5.0, // Khoảng cách dọc giữa các phần tử
          childAspectRatio: 3 / 4, // Tỷ lệ của mỗi phần tử (chiều rộng / chiều cao)
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GridTile(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProDetailScreen(product: results[index]),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          '${url.api}/images/${results[index].image}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          results[index].name,
                          style: TextStyle(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          'Giá: ${results[index].price} VND',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: -10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.black),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Đã thêm sản phẩm vào giỏ hàng!'),
                      ));
                      Provider.of<CartModel>(context, listen: false).addProduct(results[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}