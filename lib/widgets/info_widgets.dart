import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

Color statusColor(String state) {
  switch (state) {
    case 'valid':
      return AppColors.ok;
    case 'expiring':
      return AppColors.warn;
    case 'expired':
      return AppColors.bad;
    default:
      return AppColors.muted;
  }
}

IconData statusIcon(String state) {
  switch (state) {
    case 'valid':
      return Icons.check_circle_rounded;
    case 'expiring':
      return Icons.warning_amber_rounded;
    case 'expired':
      return Icons.cancel_rounded;
    default:
      return Icons.remove_circle_outline_rounded;
  }
}

/// Insurance / PUC / Fitness tile with a coloured status.
class StatusTile extends StatelessWidget {
  const StatusTile({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.date,
  });

  final String title;
  final IconData icon;
  final DocStatus status;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status.state);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(statusIcon(status.state), size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status.state == 'not_applicable'
                      ? 'N/A'
                      : status.state == 'valid'
                          ? 'Valid'
                          : status.state == 'expiring'
                              ? 'Expiring'
                              : 'Expired',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status.state == 'not_applicable' ? 'Not required' : fmtDate(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class InfoEntry {
  const InfoEntry(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;
}

/// A titled card with label/value rows. Long-press a row to copy the value.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<InfoEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: scheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          for (var i = 0; i < entries.length; i++) ...[
            InkWell(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: entries[i].value));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${entries[i].label} copied'),
                  duration: const Duration(seconds: 1),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(entries[i].label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: Text(
                        entries[i].value,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: entries[i].valueColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != entries.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16, color: borderColor(context)),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
