class Session {
  final int? id;
  final String user;
  final String date;

  Session({
    this.id,
    required this.user,
    required this.date,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      user: json['user'].toString(),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'date': date,
    };
  }
}

class SessionExercise {
  final int? id;
  final int sessionId;
  final int exerciseId;

  SessionExercise({
    this.id,
    required this.sessionId,
    required this.exerciseId,
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      id: json['id'],
      sessionId: json['session'],
      exerciseId: json['exercise'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': sessionId,
      'exercise': exerciseId,
    };
  }
}

class SessionSet {
  final int? id;
  final int sessionExerciseId;
  final double weight;
  final int reps;

  SessionSet({
    this.id,
    required this.sessionExerciseId,
    required this.weight,
    required this.reps,
  });

  factory SessionSet.fromJson(Map<String, dynamic> json) {
    return SessionSet(
      id: json['id'],
      sessionExerciseId: json['session_exercise'],
      weight: json['weight'],
      reps: json['reps'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_exercise': sessionExerciseId,
      'weight': weight,
      'reps': reps,
    };
  }
}