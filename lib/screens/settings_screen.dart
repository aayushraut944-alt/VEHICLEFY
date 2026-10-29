import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _url;
  late final TextEditingController _key;
  String? _result;
  bool _ok = false;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _url = TextEditingController(text: state.baseUrl);
    _key = TextEditingController(text: state.apiKey);
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });
    try {
      final info = await ApiService(_url.text, _key.text).health();
      setState(() {
        _ok = true;
        _result = 'Connected · ${info['vehicles']} vehicles · '
            'OCR ${info['ocr_available'] == true ? 'ready' : 'not installed'}';
      });
    } on ApiException catch (e) {
      setState(() {
        _ok = false;
        _result = e.message;
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<AppState>().saveServer(_url.text, _key.text);
    messenger.showSnackBar(const SnackBar(content: Text('Server settings saved')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backend server',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Server address',
                    hintText: 'http://192.168.1.5:5000',
                    prefixIcon: Icon(Icons.dns_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _key,
                  obscureText: true,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'API key (optional)',
                    prefixIcon: Icon(Icons.key_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _test,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.network_check_rounded),
                        label: const Text('Test'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                if (_result != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_ok ? Icons.check_circle_rounded : Icons.error_rounded,
                          color: _ok ? AppColors.ok : AppColors.bad, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_result!)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Which address should I use?\n\n'
              '• Android emulator: http://10.0.2.2:5000\n'
              '• iOS simulator / web / desktop: http://127.0.0.1:5000\n'
              '• Real phone: your computer\'s Wi-Fi address, e.g. http://192.168.1.5:5000 '
              '(phone and computer must be on the same network)',
              style: TextStyle(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
