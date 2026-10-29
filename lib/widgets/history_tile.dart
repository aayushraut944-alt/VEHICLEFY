import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/lookup_flow.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'number_plate.dart';

/// One row of the lookup history (also used on the History screen).
class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => lookupAndOpen(context, item.plate),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: NumberPlate(
                      text: item.formattedPlate, color: item.plateColor, height: 38),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.matched ? (item.vehicleName ?? 'Vehicle') : 'Not found',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: item.matched ? null : AppColors.bad,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          item.source == 'scan'
                              ? Icons.document_scanner_rounded
                              : Icons.keyboard_rounded,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            timeAgo(item.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
