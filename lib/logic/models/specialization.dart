class Specialization {
  final int id;
  final String name;
  final String? icon;
  final int? doctorsCount;

  Specialization({
    required this.id,
    required this.name,
    this.icon,
    this.doctorsCount,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      doctorsCount: json['doctors_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'doctors_count': doctorsCount,
    };
  }
}
