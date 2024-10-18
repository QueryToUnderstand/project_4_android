import 'dart:convert';

import 'package:tree/models/api.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisScreen extends StatelessWidget {
  final String uri = "${url.api}/api/register"; // API endpoint for registration
  final _keys = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(); // Controller for name
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Form(
          key: _keys,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                  'https://static.vecteezy.com/system/resources/previews/021/685/487/non_2x/register-now-label-element-design-free-vector.jpg',
                  width: 100),
              TextFormField(
                controller: _nameController, // Name field
                decoration: const InputDecoration(
                  hintText: 'Tên người dùng',
                  labelText: 'Tên người dùng',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hãy nhập tên người dùng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  labelText: 'Tên email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hãy nhập tên email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Mật khẩu',
                  labelText: 'Mật khẩu',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hãy nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_keys.currentState!.validate()) {
                    String username = _nameController.text;
                    String email = _emailController.text;
                    String password = _passwordController.text;

                    Map<String, dynamic> user = { // Changed to dynamic to match the server API
                      "name": username, // Use 'name' as per your API
                      "email": email,
                      "password": password
                    };
                    Map<String, String> headers = <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    };

                    http.post(Uri.parse(uri), headers: headers, body: jsonEncode(user))
                        .then((response) {
                      // Handle response
                      if (response.statusCode == 200) {
                        // Registration successful, handle success
                        Navigator.pop(context);
                      } else {
                        // Registration failed, show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đăng ký không thành công')),
                        );
                      }
                    });
                  }
                },
                child: Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}