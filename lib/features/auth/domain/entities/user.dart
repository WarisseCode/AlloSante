import 'package:equatable/equatable.dart';
import '../../../../core/config/api_config.dart';

enum UserRole { patient, doctor, admin }

/// Entité Utilisateur
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final UserRole role;
  final Map<String, dynamic>? doctorProfile; // Simplified for now
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
    this.role = UserRole.patient,
    this.doctorProfile,
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

  /// URL complet de l'avatar
  String? get fullProfilePictureUrl {
    if (profilePictureUrl == null) return null;
    if (profilePictureUrl!.startsWith('http')) return profilePictureUrl;
    if (profilePictureUrl!.startsWith('/')) {
      return '${ApiConfig.baseDomain}$profilePictureUrl';
    }
    return '${ApiConfig.baseDomain}/$profilePictureUrl';
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
    UserRole? role,
    Map<String, dynamic>? doctorProfile,
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
      role: role ?? this.role,
      doctorProfile: doctorProfile ?? this.doctorProfile,
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
    role,
    doctorProfile,
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
