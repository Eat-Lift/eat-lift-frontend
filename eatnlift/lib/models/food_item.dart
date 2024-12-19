class FoodItem {
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbohydrates;

  FoodItem({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
      proteins: json['proteins'],
      fats: json['fats'],
      carbohydrates: json['carbohydrates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbohydrates': carbohydrates,
    };
  }
}