class ReadingGoal {
  const ReadingGoal({
    required this.id,
    required this.year,
    required this.targetBooks,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int year;
  final int targetBooks;
  final DateTime createdAt;
  final DateTime updatedAt;
}
