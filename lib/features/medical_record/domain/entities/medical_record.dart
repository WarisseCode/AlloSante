import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final String userId;
  final String? bloodType;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final double? height;
  final double? weight;
  final String? notes;
  final DateTime updatedAt;

  const MedicalRecord({
    required this.id,
    required this.userId,
    this.bloodType,
    required this.allergies,
    required this.conditions,
    required this.medications,
    this.height,
    this.weight,
    this.notes,
    required this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      userId: json['userId'],
      bloodType: json['bloodType'],
      allergies: List<String>.from(json['allergies'] ?? []),
      conditions: List<String>.from(json['conditions'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      height: json['height'] != null
          ? (json['height'] as num).toDouble()
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      notes: json['notes'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    bloodType,
    allergies,
    conditions,
    medications,
    height,
    weight,
    notes,
    updatedAt,
  ];
}
