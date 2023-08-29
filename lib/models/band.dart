class Band {
  String id;
  String name;
  int votes;

  Band({required this.id, required this.name, required this.votes});

  factory Band.fromMap(Map<String, dynamic> bandMap) => Band(
      id: bandMap['id'] ?? 'no-id',
      name: bandMap['name'] ?? 'no-name',
      votes: bandMap['votes'] ?? 0);
}
