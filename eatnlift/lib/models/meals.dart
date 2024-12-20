class Meal {
  final int? id;
  final String user;
  final String mealType;
  final String date;

  Meal({
    this.id,
    required this.user,
    required this.mealType,
    required this.date,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      user: json['user'],
      mealType: json['meal_type'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'meal_type': mealType,
      'date': date,
    };
  }
}

class FoodItemMeal {
  final int? id;
  final int mealId;
  final String foodItemName;
  final double quantity;

  FoodItemMeal({
    this.id,
    required this.mealId,
    required this.foodItemName,
    required this.quantity,
  });

  factory FoodItemMeal.fromJson(Map<String, dynamic> json) {
    return FoodItemMeal(
      id: json['id'],
      mealId: json['meal_id'],
      foodItemName: json['food_item_name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_id': mealId,
      'food_item_name': foodItemName,
      'quantity': quantity,
    };
  }
}