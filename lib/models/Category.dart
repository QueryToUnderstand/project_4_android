class Category
{
  int id;
  String name;
  int status;

  Category(this.id, this.name, this.status);
  factory Category.fromJson(Map<String, Object?> data)
  {
    return Category(
        int.parse(data['id'].toString()),
        data['name'].toString(),
        int.parse(data['status'].toString())

    );
  }

  Map<String, Object?> toMap() {
    return {
      "categoryId": id,
      "categoryName": name,
      "status": status
    };
  }
}