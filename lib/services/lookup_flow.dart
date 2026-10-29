import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../screens/result_screen.dart';
import '../state/app_state.dart';

/// Looks a plate up on the server (with a spinner) and opens the result screen.
Future<void> lookupAndOpen(BuildContext context, String plate) async {
  final state = context.read<AppState>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final vehicle = await state.api.lookup(plate);
    navigator.pop(); // close spinner
    state.bump();
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(vehicle: vehicle)),
    );
  } on ApiException catch (e) {
    navigator.pop();
    state.bump();
    final hint = e.suggestions.isEmpty
        ? ''
        : '  Did you mean ${e.suggestions.join(', ')}?';
    messenger.showSnackBar(SnackBar(
      content: Text('${e.message}$hint'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
