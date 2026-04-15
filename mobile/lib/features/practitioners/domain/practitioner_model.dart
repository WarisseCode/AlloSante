class SpecialtyModel {
  final int id;
  final String name;
  final String slug;
  final String icon;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> j) => SpecialtyModel(
        id: j['id'] as int,
        name: j['name'] as String,
        slug: j['slug'] as String,
        icon: j['icon'] as String? ?? 'medical_services',
      );
}

class PractitionerModel {
  final int id;
  final String fullName;
  final String? title;
  final String? specialtyName;
  final String city;
  final String neighborhood;
  final String address;
  final int consultationFee;
  final int teleconsultationFee;
  final String? photoUrl;
  final List<String> languagesList;
  final double ratingAverage;
  final int reviewCount;
  final bool isAvailableToday;
  final double? latitude;
  final double? longitude;

  const PractitionerModel({
    required this.id,
    required this.fullName,
    this.title,
    this.specialtyName,
    required this.city,
    required this.neighborhood,
    required this.address,
    required this.consultationFee,
    required this.teleconsultationFee,
    this.photoUrl,
    required this.languagesList,
    required this.ratingAverage,
    required this.reviewCount,
    required this.isAvailableToday,
    this.latitude,
    this.longitude,
  });

  factory PractitionerModel.fromJson(Map<String, dynamic> j) =>
      PractitionerModel(
        id: j['id'] as int,
        fullName: j['full_name'] as String,
        title: j['title'] as String?,
        specialtyName: j['specialty_name'] as String?,
        city: j['city'] as String? ?? '',
        neighborhood: j['neighborhood'] as String? ?? '',
        address: j['address'] as String? ?? '',
        consultationFee: j['consultation_fee'] as int? ?? 0,
        teleconsultationFee: j['teleconsultation_fee'] as int? ?? 0,
        photoUrl: j['photo_url'] as String?,
        languagesList: (j['languages_list'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        ratingAverage:
            double.tryParse(j['rating_average']?.toString() ?? '0') ?? 0.0,
        reviewCount: j['review_count'] as int? ?? 0,
        isAvailableToday: j['is_available_today'] as bool? ?? false,
        latitude: double.tryParse(j['latitude']?.toString() ?? ''),
        longitude: double.tryParse(j['longitude']?.toString() ?? ''),
      );

  String get feeLabel => '${consultationFee.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      )} FCFA';
}
