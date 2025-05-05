class Counter {
  final int id;
  final int value;

  Counter({required this.id, required this.value});

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(id: json['id'] as int, value: json['value'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value};
  }
}
