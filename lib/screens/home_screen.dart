import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../services/lookup_flow.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/history_tile.dart';
import '../widgets/plate_search_field.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class _HomeData {
  const _HomeData({this.stats, this.recent = const [], this.error});
  final Stats? stats;
  final List<HistoryItem> recent;
  final String? error;
}

const _samplePlates = <(String, String)>[
  ('MH12AB1234', 'Swift'),
  ('MH04GH9087', 'Nexon EV'),
  ('GJ01UV3399', 'Tata Ace'),
  ('MH02EF4321', 'Honda City'),
  ('23BH1234AB', 'BH series'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onScan});

  /// Switches the root navigation to the Scan tab.
  final VoidCallback onScan;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seenVersion = -1;
  Future<_HomeData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = Provider.of<AppState>(context);
    if (state.version != _seenVersion) {
      _seenVersion = state.version;
      _future = _load(state);
    }
  }

  Future<_HomeData> _load(AppState state) async {
    try {
      final api = state.api;
      final stats = await api.stats();
      final recent = await api.history(limit: 5);
      return _HomeData(stats: stats, recent: recent);
    } on ApiException catch (e) {
      return _HomeData(error: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => context.read<AppState>().bump(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Hero(onScan: widget.onScan),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: FutureBuilder<_HomeData>(
                future: _future,
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data?.error != null) _OfflineBanner(message: data!.error!),
                      _StatsRow(stats: data?.stats, loading: !snap.hasData),
                      const SizedBox(height: 22),
                      const _SectionTitle('Try a sample plate'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (plate, label) in _samplePlates)
                            ActionChip(
                              avatar: const Icon(Icons.directions_car_rounded, size: 16),
                              label: Text('$plate · $label'),
                              onPressed: () => lookupAndOpen(context, plate),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: _SectionTitle('Recent lookups')),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const HistoryScreen(standalone: true)),
                            ),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      if (data != null && data.recent.isEmpty && data.error == null)
                        const _EmptyHint('Scan or search a plate and it will show up here.')
                      else
                        for (final item in data?.recent ?? const <HistoryItem>[])
                          HistoryTile(item: item),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    color: AppColors.navy, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('Vehiclefy',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const Spacer(),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Identify any vehicle\nfrom its number plate',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Owner, model, fuel, insurance, PUC and more in seconds.',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          PlateSearchField(onSubmit: (p) => lookupAndOpen(context, p)),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.navy,
            ),
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner_rounded),
            label: const Text('Scan number plate'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.loading});
  final Stats? stats;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    String value(String? v) => loading ? '…' : (v ?? '—');
    return Row(
      children: [
        Expanded(
          child: _StatTile(
              icon: Icons.garage_rounded,
              value: value(s?.totalVehicles.toString()),
              label: 'Vehicles'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
              icon: Icons.bolt_rounded,
              value: value(s?.lookupsToday.toString()),
              label: 'Lookups today'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
              icon: Icons.verified_rounded,
              value: value(s?.matchRate == null
                  ? null
                  : '${s!.matchRate!.toStringAsFixed(0)}%'),
              label: 'Match rate'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800));
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bad.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bad.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.bad),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
