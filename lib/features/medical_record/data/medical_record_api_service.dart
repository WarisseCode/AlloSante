import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../domain/entities/medical_record.dart';

class MedicalRecordApiService {
  final ApiClient _apiClient = ApiClient();

  /// Récupérer le dossier médical de l'utilisateur
  Future<MedicalRecord> getMedicalRecord() async {
    try {
      final response = await _apiClient.get('/medical-record');
      // Backend returns { medicalRecord: ... }
      return MedicalRecord.fromJson(response.data['medicalRecord']);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw e.response!.data['error'];
      }
      throw 'Erreur lors du chargement du dossier médical';
    }
  }

  /// Mettre à jour le dossier médical
  Future<MedicalRecord> updateMedicalRecord({
    String? bloodType,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    double? height,
    double? weight,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/medical-record',
        data: {
          if (bloodType != null) 'bloodType': bloodType,
          if (allergies != null) 'allergies': allergies,
          if (conditions != null) 'conditions': conditions,
          if (medications != null) 'medications': medications,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
        },
      );
      return MedicalRecord.fromJson(response.data['medicalRecord']);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw e.response!.data['error'];
      }
      throw 'Erreur lors de la mise à jour';
    }
  }
}
