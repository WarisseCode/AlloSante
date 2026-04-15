import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/practitioner_model.dart';

class PractitionersRepository {
  final _client = ApiClient.instance;

  Future<List<SpecialtyModel>> getSpecialties() async {
    final resp = await _client.dio.get(ApiConfig.specialties);
    return (resp.data as List)
        .map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PractitionerModel>> getPractitioners({
    String? query,
    String? specialty,
    String? city,
    String? neighborhood,
    String? gender,
    int? maxFee,
    bool? availableToday,
    bool? teleconsultation,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (specialty != null) params['specialty'] = specialty;
    if (city != null) params['city'] = city;
    if (neighborhood != null) params['neighborhood'] = neighborhood;
    if (gender != null) params['gender'] = gender;
    if (maxFee != null) params['max_fee'] = maxFee;
    if (availableToday == true) params['available_today'] = 'true';
    if (teleconsultation == true) params['teleconsultation'] = 'true';

    final resp = await _client.dio.get(
      ApiConfig.practitioners,
      queryParameters: params,
    );

    final results = resp.data['results'] as List? ?? resp.data as List;
    return results
        .map((e) => PractitionerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPractitionerDetail(int id) async {
    final resp = await _client.dio.get(ApiConfig.practitionerDetail(id));
    return resp.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTimeSlots(
    int practitionerId, {
    String? dateFrom,
    bool? teleconsultation,
  }) async {
    final params = <String, dynamic>{};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (teleconsultation == true) params['teleconsultation'] = 'true';

    final resp = await _client.dio.get(
      ApiConfig.practitionerSlots(practitionerId),
      queryParameters: params,
    );
    final results = resp.data['results'] as List? ?? resp.data as List;
    return results.map((e) => e as Map<String, dynamic>).toList();
  }
}
