String? _s(dynamic v) => v?.toString();
int? _i(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

/// Insurance / PUC / fitness status as computed by the server.
class DocStatus {
  const DocStatus({required this.state, required this.label, this.daysLeft});

  /// valid | expiring | expired | not_applicable
  final String state;
  final String label;
  final int? daysLeft;

  factory DocStatus.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return const DocStatus(state: 'not_applicable', label: 'Not applicable');
    }
    return DocStatus(
      state: _s(j['state']) ?? 'not_applicable',
      label: _s(j['label']) ?? '',
      daysLeft: _i(j['days_left']),
    );
  }
}

class Vehicle {
  const Vehicle({
    required this.registrationNumber,
    required this.formattedRegistration,
    required this.plateColor,
    required this.maker,
    required this.model,
    required this.ownerName,
    required this.fuelType,
    required this.insurance,
    required this.pucc,
    required this.fitness,
    this.state,
    this.registrationDate,
    this.rtoOffice,
    this.ownerSerial = 1,
    this.variant,
    this.vehicleClass,
    this.emissionNorm,
    this.color,
    this.manufacturingYear,
    this.vehicleAgeYears,
    this.engineCc,
    this.seatingCapacity,
    this.chassisNumber,
    this.engineNumber,
    this.fitnessValidUpto,
    this.insuranceCompany,
    this.insurancePolicyNo,
    this.insuranceValidUpto,
    this.puccValidUpto,
    this.financer,
  });

  final String registrationNumber;
  final String formattedRegistration;
  final String plateColor; // white | yellow | green
  final String? state;
  final String? registrationDate;
  final String? rtoOffice;
  final String ownerName;
  final int ownerSerial;
  final String maker;
  final String model;
  final String? variant;
  final String? vehicleClass;
  final String fuelType;
  final String? emissionNorm;
  final String? color;
  final int? manufacturingYear;
  final int? vehicleAgeYears;
  final int? engineCc;
  final int? seatingCapacity;
  final String? chassisNumber;
  final String? engineNumber;
  final String? fitnessValidUpto;
  final String? insuranceCompany;
  final String? insurancePolicyNo;
  final String? insuranceValidUpto;
  final String? puccValidUpto;
  final String? financer;
  final DocStatus insurance;
  final DocStatus pucc;
  final DocStatus fitness;

  String get title => '$maker $model';

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    final status = j['status'] as Map<String, dynamic>?;
    DocStatus doc(String key) =>
        DocStatus.fromJson(status?[key] as Map<String, dynamic>?);

    return Vehicle(
      registrationNumber: _s(j['registration_number']) ?? '',
      formattedRegistration: _s(j['formatted_registration']) ??
          _s(j['registration_number']) ??
          '',
      plateColor: _s(j['plate_color']) ?? 'white',
      state: _s(j['state']),
      registrationDate: _s(j['registration_date']),
      rtoOffice: _s(j['rto_office']),
      ownerName: _s(j['owner_name']) ?? '—',
      ownerSerial: _i(j['owner_serial']) ?? 1,
      maker: _s(j['maker']) ?? '',
      model: _s(j['model']) ?? '',
      variant: _s(j['variant']),
      vehicleClass: _s(j['vehicle_class']),
      fuelType: _s(j['fuel_type']) ?? '—',
      emissionNorm: _s(j['emission_norm']),
      color: _s(j['color']),
      manufacturingYear: _i(j['manufacturing_year']),
      vehicleAgeYears: _i(j['vehicle_age_years']),
      engineCc: _i(j['engine_cc']),
      seatingCapacity: _i(j['seating_capacity']),
      chassisNumber: _s(j['chassis_number']),
      engineNumber: _s(j['engine_number']),
      fitnessValidUpto: _s(j['fitness_valid_upto']),
      insuranceCompany: _s(j['insurance_company']),
      insurancePolicyNo: _s(j['insurance_policy_no']),
      insuranceValidUpto: _s(j['insurance_valid_upto']),
      puccValidUpto: _s(j['pucc_valid_upto']),
      financer: _s(j['financer']),
      insurance: doc('insurance'),
      pucc: doc('pucc'),
      fitness: doc('fitness'),
    );
  }
}

/// Response of POST /api/scan.
class ScanResult {
  const ScanResult({
    required this.found,
    required this.matchType,
    required this.detectedPlate,
    required this.formattedPlate,
    required this.confidence,
    required this.candidates,
    this.vehicle,
  });

  final bool found;

  /// exact | fuzzy | none
  final String matchType;
  final String detectedPlate;
  final String formattedPlate;
  final double confidence;
  final List<String> candidates;
  final Vehicle? vehicle;

  factory ScanResult.fromJson(Map<String, dynamic> j) {
    final v = j['vehicle'];
    return ScanResult(
      found: j['found'] == true,
      matchType: _s(j['match_type']) ?? 'none',
      detectedPlate: _s(j['detected_plate']) ?? '',
      formattedPlate: _s(j['formatted_plate']) ?? _s(j['detected_plate']) ?? '',
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
      candidates: ((j['candidates'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      vehicle: v is Map<String, dynamic> ? Vehicle.fromJson(v) : null,
    );
  }
}

class HistoryItem {
  const HistoryItem({
    required this.plate,
    required this.formattedPlate,
    required this.source,
    required this.matched,
    required this.createdAt,
    required this.plateColor,
    this.confidence,
    this.vehicleName,
  });

  final String plate;
  final String formattedPlate;
  final String source; // scan | search
  final bool matched;
  final DateTime createdAt;
  final String plateColor;
  final double? confidence;
  final String? vehicleName;

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        plate: _s(j['plate']) ?? '',
        formattedPlate: _s(j['formatted_plate']) ?? _s(j['plate']) ?? '',
        source: _s(j['source']) ?? 'search',
        matched: j['matched'] == true,
        createdAt: DateTime.tryParse(_s(j['created_at']) ?? '') ?? DateTime.now(),
        plateColor: _s(j['plate_color']) ?? 'white',
        confidence: (j['confidence'] as num?)?.toDouble(),
        vehicleName: _s(j['vehicle_name']),
      );
}

class Stats {
  const Stats({
    required this.totalVehicles,
    required this.lookupsToday,
    required this.insuranceExpired,
    this.matchRate,
  });

  final int totalVehicles;
  final int lookupsToday;
  final int insuranceExpired;
  final double? matchRate;

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        totalVehicles: _i(j['total_vehicles']) ?? 0,
        lookupsToday: _i(j['lookups_today']) ?? 0,
        insuranceExpired: _i(j['insurance_expired']) ?? 0,
        matchRate: (j['match_rate'] as num?)?.toDouble(),
      );
}

class ApiException implements Exception {
  ApiException(this.message,
      {this.code, this.status, this.suggestions = const []});

  final String message;
  final String? code;
  final int? status;
  final List<String> suggestions;

  @override
  String toString() => message;
}
