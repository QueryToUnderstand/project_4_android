import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/screens/proDetail_screen.dart';
import 'package:tree/screens/product_screen.dart';
import '../models/Account.dart';
import '../models/Cart.dart';
import '../models/Category.dart';
import '../models/Product.dart';
import '../models/api.dart';
import 'package:http/http.dart' as http;
import 'account.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'homePage_screen.dart';
import 'login_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int category;
  ProductListScreen({required this.category});

  @override
  _ProductListScreenState createState() =>_ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> product = [];
  bool isLoggedIn = false;
  int _currentIndex = 0;
  String categoryName = "";

  @override
  void initState() {
    super.initState();
    fetchProduct();
    checkLoginStatus();
    fetchCategoryName();
  }

  Future<void> fetchProduct() async {
    final response = await http.get(Uri.parse('${url.api}/api/product-by-category/${widget.category}'));

    print(widget.category);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        product = (data['result'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      });
    } else {
      throw Exception('Không thể tải sản phẩm: ${response.reasonPhrase}');
    }
  }

  Future<void> checkLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");
    setState(() {
      isLoggedIn = id != null;
    });
  }

  Future<void> fetchCategoryName() async {
    final response = await http.get(Uri.parse('${url.api}/api/category/${widget.category}'));

    print(widget.category);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data: $data');
      setState(() {
        categoryName = data['result']['name'] ?? 'Danh mục không xác định';
      });
    } else {
      throw Exception('Không thể tải tên danh mục: ${response.reasonPhrase}');
    }
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<Account> getAccountInfo() async {
    var prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");
    String? name = prefs.getString("fullName");

    if (id != null && name != null) {
      return Account(id: id, name: name);
    } else {
      throw Exception('Tài khoản không tồn tại');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(categoryName.isNotEmpty ? categoryName : 'Danh mục'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Consumer<CartModel>(
                    builder: (context, cart, child) {
                      return Text(
                        '${cart.items.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if (result == 'account') {
                Account account = await getAccountInfo();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountInfoScreen(account: account),
                  ),
                );
              } else if (result == 'logout') {
                await logout();
              } else if (result == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              if (isLoggedIn) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'account',
                    child: Text('Thông tin tài khoản'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Đăng xuất'),
                  ),
                ];
              } else {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: Text('Đăng nhập'),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: product.isEmpty
          ? Text("danh mục trống")
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số cột trong GridView
          crossAxisSpacing: 8.0, // Khoảng cách ngang giữa các phần tử
          mainAxisSpacing: 5.0, // Khoảng cách dọc giữa các phần tử
          childAspectRatio: 3 / 4, // Tỷ lệ của mỗi phần tử (chiều rộng / chiều cao)
        ),
        itemCount: product.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GridTile(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProDetailScreen(product: product[index]),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          '${url.api}/images/${product[index].image}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product[index].name,
                          style: TextStyle(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          'Giá KM: ${product[index].sale_price} VND',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.red
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
                child: Container(// Padding bên trong Container
                  decoration: BoxDecoration(// Màu nền cho Container
                    borderRadius: BorderRadius.circular(5.0), // Bo góc Container
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.black),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Đã thêm sản phẩm vào giỏ hàng!')));
                      Provider.of<CartModel>(context, listen: false)
                          .addProduct(product[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Danh mục',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

