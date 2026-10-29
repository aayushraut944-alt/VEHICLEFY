import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../state/app_state.dart';
import '../widgets/history_tile.dart';

class HistoryScreen extends StatefulWidget {
  /// [standalone] is true when pushed as its own page (shows a back button).
  const HistoryScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _seenVersion = -1;
  Future<List<HistoryItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = Provider.of<AppState>(context);
    if (state.version != _seenVersion) {
      _seenVersion = state.version;
      _future = state.api.history(limit: 60);
    }
  }

  Future<void> _clear() async {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved lookups will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await state.api.clearHistory();
      state.bump();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.standalone,
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _clear,
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final items = snap.data ?? const <HistoryItem>[];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 10),
                  const Text('No lookups yet'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<AppState>().bump(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => HistoryTile(item: items[i]),
            ),
          );
        },
      ),
    );
  }
}
