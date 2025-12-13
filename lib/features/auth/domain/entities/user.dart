import 'package:equatable/equatable.dart';

/// Entité Utilisateur
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.address,
    this.city,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  /// Nom complet
  String get fullName => '$firstName $lastName';

  /// Initiales pour l'avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Numéro de téléphone formaté
  String get formattedPhone {
    if (phone == null) return '';
    final cleaned = phone!.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 8) {
      return '+229 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)}';
    }
    return phone!;
  }

  /// Copier avec modifications
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        firstName,
        lastName,
        profilePictureUrl,
        dateOfBirth,
        address,
        city,
        isVerified,
        createdAt,
        updatedAt,
      ];
}

/// Credentials pour l'authentification
class AuthCredentials extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final User user;

  const AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  /// Vérifier si le token est expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Temps restant avant expiration
  Duration get timeToExpiration => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, user];
}
