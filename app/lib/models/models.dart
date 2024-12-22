class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class Group {
  final String id;
  final String name;
  final List<String> members;

  Group({required this.id, required this.name, required this.members});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'members': members};
  }
}

class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'splitBetween': splitBetween,
      'date': date.toIso8601String(),
    };
  }
}

class Payment {
  final String id;
  final String fromUser;
  final String toUser;
  final double amount;
  final DateTime date;

  Payment({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUser': fromUser,
      'toUser': toUser,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
