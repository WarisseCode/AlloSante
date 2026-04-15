class UserModel {
  final int id;
  final String? phoneNumber;
  final String? email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final bool isVerified;

  const UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        phoneNumber: json['phone_number'] as String?,
        email: json['email'] as String?,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        isVerified: json['is_verified'] as bool,
      );

  bool get isPatient => role == 'patient';
  bool get isPractitioner => role == 'practitioner';
}
