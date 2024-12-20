class UserProfile {
  final int? calories;
  final int? proteins;
  final int? fats;
  final int? carbohydrates;

  UserProfile({
    this.calories,
    this.proteins,
    this.fats,
    this.carbohydrates,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      calories: json['calories'],
      proteins: json['proteins'],
      fats: json['fats'],
      carbohydrates: json['carbohydrates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbohydrates': carbohydrates,
    };
  }
}