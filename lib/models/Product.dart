import 'dart:convert';

class Product
{
  final int id;
  final String name;
  final double price;
  final double sale_price;
  final String image;
  final int status;
  final String description;
  final int category_id;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sale_price,
    required this.image,
    required this.status,
    required this.description,
    required this.category_id});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      sale_price: json['sale_price'].toDouble(),
      image: json['image'],
      status: json['status'],
      description: json['description'],
      category_id: json['category_id'],
    );
  }
}