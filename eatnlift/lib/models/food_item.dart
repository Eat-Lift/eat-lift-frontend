class FoodItem {
  final int? id;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final String user;
  final double carbohydrates;

  FoodItem({
    this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.user,
    required this.carbohydrates,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      proteins: json['proteins'],
      fats: json['fats'],
      user: json['user'],
      carbohydrates: json['carbohydrates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'user': user,
      'carbohydrates': carbohydrates,
    };
  }
}