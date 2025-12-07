class Doctor {
  final int? id;
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final String biography;
  final String hospital;
  final String contact;
  final String? email;
  final String? phone;
  final String? address;
  final double? price;
  final int? specializationId;

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.biography,
    required this.hospital,
    required this.contact,
    this.email,
    this.phone,
    this.address,
    this.price,
    this.specializationId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      specialty: json['specialization']?['name'] as String? ?? 
                 json['specialty'] as String? ?? '',
      rating: (json['rating'] ?? json['degree'] ?? 4.5).toDouble(),
      image: json['photo'] as String? ?? json['image'] as String? ?? '',
      biography: json['bio'] as String? ?? 
                 json['biography'] as String? ?? 
                 'No biography available',
      hospital: json['hospital'] as String? ?? 
                json['clinic'] as String? ?? 
                'Hospital information not available',
      contact: json['phone'] as String? ?? json['contact'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      price: (json['appoint_price'] ?? json['price'])?.toDouble(),
      specializationId: json['specialization']?['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'image': image,
      'biography': biography,
      'hospital': hospital,
      'contact': contact,
      'email': email,
      'phone': phone,
      'address': address,
      'price': price,
      'specialization_id': specializationId,
    };
  }
}
