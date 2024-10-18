import 'dart:core';

class Account
{
  final int id;
  final String name;

  Account({required this.id, required this.name});
  factory Account.fromJson(Map<String, dynamic> json)
  {
    return Account(
      id: json['id'] is int ? json['id'] : int.parse(json['id']), // Ensure id is int
      name: json['name'],

    );
  }
}