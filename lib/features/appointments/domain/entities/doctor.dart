import 'package:equatable/equatable.dart';

/// Entité Médecin
class Doctor extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String? profilePictureUrl;
  final String location;
  final String? address;
  final double rating;
  final int reviewCount;
  final int consultationPrice;
  final List<String> languages;
  final List<String> availableDays;
  final bool isAvailable;
  final String? bio;
  final int experienceYears;

  const Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    this.profilePictureUrl,
    required this.location,
    this.address,
    required this.rating,
    required this.reviewCount,
    required this.consultationPrice,
    required this.languages,
    required this.availableDays,
    required this.isAvailable,
    this.bio,
    required this.experienceYears,
  });

  /// Nom complet du médecin
  String get fullName => 'Dr. $firstName $lastName';

  /// Initiales pour l'avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Prix formaté
  String get formattedPrice => '$consultationPrice FCFA';

  /// Rating formaté
  String get formattedRating => rating.toStringAsFixed(1);

  /// Copier avec modifications
  Doctor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? specialty,
    String? profilePictureUrl,
    String? location,
    String? address,
    double? rating,
    int? reviewCount,
    int? consultationPrice,
    List<String>? languages,
    List<String>? availableDays,
    bool? isAvailable,
    String? bio,
    int? experienceYears,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      consultationPrice: consultationPrice ?? this.consultationPrice,
      languages: languages ?? this.languages,
      availableDays: availableDays ?? this.availableDays,
      isAvailable: isAvailable ?? this.isAvailable,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }

  /// Convertir en Map pour le stockage local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'specialty': specialty,
      'profile_picture_url': profilePictureUrl,
      'location': location,
      'address': address,
      'rating': rating,
      'review_count': reviewCount,
      'consultation_price': consultationPrice,
      'languages': languages,
      'available_days': availableDays,
      'is_available': isAvailable,
      'bio': bio,
      'experience_years': experienceYears,
    };
  }

  /// Créer depuis un Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      specialty: map['specialty'] as String,
      profilePictureUrl: map['profile_picture_url'] as String?,
      location: map['location'] as String,
      address: map['address'] as String?,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['review_count'] as int,
      consultationPrice: map['consultation_price'] as int,
      languages: List<String>.from(map['languages'] ?? []),
      availableDays: List<String>.from(map['available_days'] ?? []),
      isAvailable: map['is_available'] as bool? ?? true,
      bio: map['bio'] as String?,
      experienceYears: map['experience_years'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        specialty,
        profilePictureUrl,
        location,
        address,
        rating,
        reviewCount,
        consultationPrice,
        languages,
        availableDays,
        isAvailable,
        bio,
        experienceYears,
      ];
}

/// Spécialités médicales
class MedicalSpecialty {
  static const List<String> specialties = [
    'Médecine Générale',
    'Cardiologie',
    'Dermatologie',
    'Gynécologie',
    'Pédiatrie',
    'Ophtalmologie',
    'ORL',
    'Dentiste',
    'Neurologie',
    'Psychiatrie',
    'Orthopédie',
    'Urologie',
    'Gastro-entérologie',
    'Pneumologie',
    'Endocrinologie',
    'Radiologie',
    'Chirurgie Générale',
    'Kinésithérapie',
    'Nutritionniste',
    'Sage-femme',
  ];
}

/// Localisations au Bénin
class BeninLocations {
  static const List<String> cities = [
    'Cotonou',
    'Porto-Novo',
    'Parakou',
    'Abomey-Calavi',
    'Bohicon',
    'Natitingou',
    'Lokossa',
    'Djougou',
    'Ouidah',
    'Malanville',
  ];
}
