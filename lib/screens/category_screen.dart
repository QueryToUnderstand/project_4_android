import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/screens/proDetail_screen.dart';
import 'package:tree/screens/productList_screen.dart';
import 'package:tree/screens/product_screen.dart';
import 'package:tree/screens/search_results_screen.dart';
import '../models/Account.dart';
import '../models/Cart.dart';
import '../models/Category.dart';
import '../models/Product.dart';
import '../models/api.dart';
import 'package:http/http.dart' as http;
import 'account.dart';
import 'cart_screen.dart';
import 'homePage_screen.dart';
import 'login_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() =>_CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> category = [];
  bool isLoggedIn = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCategory();
    checkLoginStatus();
  }

  Future<void> fetchCategory() async {
    final response = await http.get(Uri.parse('${url.api}/api/category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        category = (data['result'] as List)
            .map((category) => Category.fromJson(category))
            .toList();
      });
    } else {
      throw Exception('Không thể tải danh mục');
    }
  }

  Future<void> checkLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");
    setState(() {
      isLoggedIn = id != null;
    });
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

  Future<void> _searchProducts() async {
    String? searchQuery = await showSearchDialog(context);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: searchQuery),
        ),
      );
    }
  }

  Future<String?> showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tìm kiếm sản phẩm'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Nhập tên sản phẩm'),
          ),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tìm kiếm'),
              onPressed: () {
                Navigator.of(context).pop(searchController.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục hàng'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchProducts,
          ),
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
      body: category.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: category.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${category[index].name} '), // Hiển thị số lượng sản phẩm
                Icon(Icons.arrow_forward_ios), // Biểu tượng bên phải
              ],
            ),
            onTap: () {
              // Điều hướng đến màn hình sản phẩm theo danh mục
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>   ProductListScreen(category: category[index].id),
                ),
              );
            },
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

