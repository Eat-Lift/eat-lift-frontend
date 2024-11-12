class FoodItem {
  final String name;
  final int calories;
  final double proteins;
  final double fats;
  final double carbohydrates;
  final String creator;

  FoodItem({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
    required this.creator,
  });

  factory FoodItem.create({
    required String name,
    required int calories,
    required double proteins,
    required double fats,
    required double carbohydrates,
    required String creator,
  }) {
    final List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add("Es requereix el nom de l'aliment");
    }
    if (calories <= 0) {
      errors.add("Es requereixen les calories");
    }
    if (proteins < 0) {
      errors.add("Es requereixen les proteïnes");
    }
    if (fats < 0) {
      errors.add("Es requereixen els greixos");
    }
    if (carbohydrates < 0) {
      errors.add("Es requereixen els carbohidrats");
    }
    if (creator.isEmpty) {
      errors.add("Es requereix l'ID del creador");
    }

    final estimatedCalories = (proteins * 4) + (fats * 9) + (carbohydrates * 4);
    if ((calories - estimatedCalories).abs() > 50) {
      errors.add("Les calories no coincideixen amb els macronutrients");
    }

    if (errors.isNotEmpty) {
      throw Exception(errors);
    }

    return FoodItem(
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbohydrates: carbohydrates,
      creator: creator,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'proteins': proteins,
    'fats': fats,
    'carbohydrates': carbohydrates,
    'creator': creator,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
      proteins: json['proteins'],
      fats: json['fats'],
      carbohydrates: json['carbohydrates'],
      creator: json['creator'],
    );
  }
}