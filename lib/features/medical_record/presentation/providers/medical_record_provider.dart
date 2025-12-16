import 'package:flutter/foundation.dart';
import '../../data/medical_record_api_service.dart';
import '../../domain/entities/medical_record.dart';

class MedicalRecordProvider extends ChangeNotifier {
  final MedicalRecordApiService _apiService = MedicalRecordApiService();

  MedicalRecord? _record;
  bool _isLoading = false;
  String? _error;

  MedicalRecord? get record => _record;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMedicalRecord() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _record = await _apiService.getMedicalRecord();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMedicalRecord({
    String? bloodType,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    double? height,
    double? weight,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _record = await _apiService.updateMedicalRecord(
        bloodType: bloodType,
        allergies: allergies,
        conditions: conditions,
        medications: medications,
        height: height,
        weight: weight,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
