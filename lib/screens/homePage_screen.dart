import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree/screens/proDetail_screen.dart';
import 'package:tree/screens/product_screen.dart';
import 'package:tree/screens/search_results_screen.dart';
import '../models/Account.dart';
import '../models/Cart.dart';
import '../models/Product.dart';
import '../models/api.dart';
import 'package:http/http.dart' as http;
import 'account.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'login_screen.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() =>_HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Product> product = [];
  bool isLoggedIn = false;
  int _currentIndex = 0; //
  // Biến để theo dõi tab hiện tại
  final List<String> carouselImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHyAKYSN4UrbKt5cqHjo91JNsi14pMz3YrTQ&s',
    'https://vuoncayviet.com/data/aditems/93/vuon-cay-viet-banner-new.jpg',
    'https://vivina.net/static/media/images/product-category/2021_09_12/bannercollection-1631464325.jpg'
    // Thêm các URL hình ảnh khác ở đây
  ];

  @override
  void initState() {
    super.initState();
    fetchProduct();
    checkLoginStatus();
  }

  Future<void> fetchProduct() async {
    final response = await http.get(Uri.parse('${url.api}/api/product'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        product = (data['result'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      });
    } else {
      throw Exception('Không thể tải sản phẩm');
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
            keyboardType: TextInputType.multiline,
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
        title: Text('Trang chủ'),
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
      body: product.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Banner
          SliverToBoxAdapter(
            child: Container(
              height: 200, // Chiều cao của carousel
              child: PageView.builder(
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    carouselImages[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          // Tiêu đề danh sách cuộn ngang
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Padding cho tiêu đề
              child: Text(
                'Các sản phẩm nổi bật', // Tiêu đề
                style: TextStyle(
                  fontSize: 20.0, // Kích thước chữ tiêu đề
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Times New Roman',
                  color:Colors.yellow.shade700,// Đậm chữ
                ),
              ),
            ),
          ),
          // Danh sách cuộn ngang
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              color:Colors.teal[100],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product.length, // Hoặc số lượng sản phẩm muốn hiển thị
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    color:Colors.white,// Chiều rộng của từng item
                    margin: EdgeInsets.all(8.0),
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
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              product[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              'Giá KM: ${product[index].sale_price} VND',
                              style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red
                              ),
                            ),

                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Padding tùy chỉnh
              child: Container(
                width: double.infinity,
                color:Colors.teal[100],
                child: Image.network(
                  'https://danviet.mediacdn.vn/296231569849192448/2023/2/19/luoi-ho-cay-canh-14-16768300685381062446504.jpg',
                  height: 400, // Chiều cao của poster
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Đảm bảo hình ảnh che phủ toàn bộ Container
                ),
              ),
            ),
          ),
          // Tiêu đề danh sách sản phẩm
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Padding cho tiêu đề
              child: Text(
                'Gợi ý riêng cho bạn!', // Tiêu đề
                style: TextStyle(
                  fontSize: 18.0, // Kích thước chữ tiêu đề// Đậm chữ
                ),
              ),
            ),
          ),
          // Danh sách sản phẩm
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số cột trong GridView
              crossAxisSpacing: 8.0, // Khoảng cách ngang giữa các phần tử
              mainAxisSpacing: 5.0, // Khoảng cách dọc giữa các phần tử
              childAspectRatio: 3 / 4, // Tỷ lệ của mỗi phần tử (chiều rộng / chiều cao)
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                              padding: const EdgeInsets.all(2.0),
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
                      child: Container(
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
              childCount: product.length,
            ),
          ),
        ],
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

