import 'package:flutter_test/flutter_test.dart';
import 'package:vehiclefy/models/vehicle.dart';
import 'package:vehiclefy/utils/format.dart';

void main() {
  test('Vehicle.fromJson maps API fields', () {
    final v = Vehicle.fromJson({
      'registration_number': 'MH12AB1234',
      'formatted_registration': 'MH 12 AB 1234',
      'plate_color': 'white',
      'owner_name': 'Rahul Deshmukh',
      'maker': 'Maruti Suzuki',
      'model': 'Swift',
      'fuel_type': 'Petrol',
      'engine_cc': 1197,
      'status': {
        'insurance': {'state': 'valid', 'label': 'Valid', 'days_left': 210},
      },
    });
    expect(v.title, 'Maruti Suzuki Swift');
    expect(v.engineCc, 1197);
    expect(v.insurance.state, 'valid');
    expect(v.pucc.state, 'not_applicable'); // missing -> safe default
  });

  test('format helpers', () {
    expect(fmtDate('2026-10-29'), '29 Oct 2026');
    expect(fmtDate(null), '—');
    expect(ordinal(1), '1st');
    expect(ordinal(12), '12th');
    expect(ordinal(23), '23rd');
  });
}
