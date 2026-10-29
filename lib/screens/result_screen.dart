import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/info_widgets.dart';
import '../widgets/number_plate.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.vehicle, this.scan});

  final Vehicle vehicle;

  /// Present when the vehicle was found by scanning a photo.
  final ScanResult? scan;

  String _summary() {
    final v = vehicle;
    return [
      'Vehiclefy report',
      'Registration No: ${v.formattedRegistration}',
      'Owner: ${v.ownerName} (${ordinal(v.ownerSerial)} owner)',
      'Vehicle: ${v.title} ${v.variant ?? ''}'.trim(),
      'Class: ${dash(v.vehicleClass)}',
      'Fuel: ${v.fuelType} (${dash(v.emissionNorm)})',
      'Colour: ${dash(v.color)}',
      'Mfg year: ${dash(v.manufacturingYear)}',
      'Registered: ${fmtDate(v.registrationDate)} at ${dash(v.rtoOffice)}',
      'Chassis No: ${dash(v.chassisNumber)}',
      'Engine No: ${dash(v.engineNumber)}',
      'Insurance: ${dash(v.insuranceCompany)} - valid upto ${fmtDate(v.insuranceValidUpto)}',
      'PUC valid upto: ${fmtDate(v.puccValidUpto)}',
      'Fitness valid upto: ${fmtDate(v.fitnessValidUpto)}',
      'Financer: ${v.financer ?? 'None'}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle details'),
        actions: [
          IconButton(
            tooltip: 'Copy details',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _summary()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vehicle details copied')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (scan != null) _ScanBanner(scan: scan!),
          _Hero(vehicle: v),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatusTile(
                  title: 'Insurance',
                  icon: Icons.shield_rounded,
                  status: v.insurance,
                  date: v.insuranceValidUpto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusTile(
                  title: 'PUC',
                  icon: Icons.air_rounded,
                  status: v.pucc,
                  date: v.puccValidUpto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusTile(
                  title: 'Fitness',
                  icon: Icons.build_circle_rounded,
                  status: v.fitness,
                  date: v.fitnessValidUpto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InfoCard(
            title: 'Registration details',
            icon: Icons.badge_rounded,
            entries: [
              InfoEntry('Registration No.', v.formattedRegistration),
              InfoEntry('Registered on', fmtDate(v.registrationDate)),
              InfoEntry('Registering authority', dash(v.rtoOffice)),
              InfoEntry('State', dash(v.state)),
              InfoEntry('Owner name', v.ownerName),
              InfoEntry('Ownership', '${ordinal(v.ownerSerial)} owner'),
            ],
          ),
          InfoCard(
            title: 'Vehicle details',
            icon: Icons.directions_car_rounded,
            entries: [
              InfoEntry('Maker', v.maker),
              InfoEntry('Model', v.model),
              InfoEntry('Variant', dash(v.variant)),
              InfoEntry('Vehicle class', dash(v.vehicleClass)),
              InfoEntry('Fuel type', v.fuelType),
              InfoEntry('Emission norms', dash(v.emissionNorm)),
              InfoEntry('Colour', dash(v.color)),
              InfoEntry('Manufacturing year', dash(v.manufacturingYear)),
              InfoEntry('Vehicle age',
                  v.vehicleAgeYears == null ? '—' : '${v.vehicleAgeYears} yrs'),
              InfoEntry('Engine capacity',
                  v.engineCc == null ? 'N/A (electric)' : '${v.engineCc} cc'),
              InfoEntry('Seating capacity', dash(v.seatingCapacity)),
            ],
          ),
          InfoCard(
            title: 'Identification',
            icon: Icons.fingerprint_rounded,
            entries: [
              InfoEntry('Chassis No.', dash(v.chassisNumber)),
              InfoEntry('Engine / motor No.', dash(v.engineNumber)),
            ],
          ),
          InfoCard(
            title: 'Insurance & compliance',
            icon: Icons.verified_user_rounded,
            entries: [
              InfoEntry('Insurer', dash(v.insuranceCompany)),
              InfoEntry('Policy No.', dash(v.insurancePolicyNo)),
              InfoEntry('Insurance valid upto', fmtDate(v.insuranceValidUpto),
                  valueColor: statusColor(v.insurance.state)),
              InfoEntry(
                'PUC valid upto',
                v.pucc.state == 'not_applicable'
                    ? 'Exempt'
                    : fmtDate(v.puccValidUpto),
                valueColor: statusColor(v.pucc.state),
              ),
              InfoEntry('Fitness valid upto', fmtDate(v.fitnessValidUpto),
                  valueColor: statusColor(v.fitness.state)),
            ],
          ),
          InfoCard(
            title: 'Finance',
            icon: Icons.account_balance_rounded,
            entries: [
              InfoEntry('Hypothecation / financer',
                  v.financer ?? 'None (no active loan)'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Long-press any row to copy its value.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: NumberPlate(
                text: v.formattedRegistration, color: v.plateColor, height: 64),
          ),
          const SizedBox(height: 20),
          Text(
            v.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (v.variant != null && v.variant!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(v.variant!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(Icons.local_gas_station_rounded, v.fuelType),
              if (v.manufacturingYear != null)
                _Pill(Icons.calendar_month_rounded, '${v.manufacturingYear}'),
              if (v.color != null) _Pill(Icons.palette_rounded, v.color!),
              if (v.seatingCapacity != null)
                _Pill(Icons.event_seat_rounded, '${v.seatingCapacity} seats'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.amber),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget {
  const _ScanBanner({required this.scan});
  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    final fuzzy = scan.matchType == 'fuzzy';
    final color = fuzzy ? AppColors.warn : AppColors.ok;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(fuzzy ? Icons.rule_rounded : Icons.document_scanner_rounded,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fuzzy
                  ? 'Closest match to "${scan.formattedPlate}" '
                      '(${scan.confidence.toStringAsFixed(0)}% read confidence). '
                      'Please verify the plate.'
                  : 'Read "${scan.formattedPlate}" from your photo '
                      '(${scan.confidence.toStringAsFixed(0)}% confidence).',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
