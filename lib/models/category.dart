class Category {
  final String title;
  bool isChecked;
  final String dbName;

  Category({
    required this.title,
    this.isChecked = false,
    required this.dbName,
  });
}
