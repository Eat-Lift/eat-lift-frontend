class Exercise {
  final int? id;
  final String name;
  final String? description;
  final String user;
  final List<String> trainedMuscles;

  Exercise({
    this.id,
    required this.name,
    this.description,
    required this.user,
    required this.trainedMuscles,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      user: json['user'],
      trainedMuscles: (json['trained_muscles'] as String).split(','),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user': user,
      'trained_muscles': trainedMuscles.join(','),
    };
  }
}