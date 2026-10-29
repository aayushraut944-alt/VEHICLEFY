import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../services/lookup_flow.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/number_plate.dart';
import '../widgets/plate_search_field.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  Uint8List? _bytes;
  bool _busy = false;
  ApiException? _error;
  ScanResult? _unmatched;

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final state = context.read<AppState>();
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _busy = true;
        _error = null;
        _unmatched = null;
      });
      _sweep.repeat(reverse: true);

      final result = await state.api.scan(bytes, file.name);
      if (!mounted) return;
      state.bump();
      _sweep.stop();
      setState(() => _busy = false);

      if (result.found && result.vehicle != null) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ResultScreen(vehicle: result.vehicle!, scan: result),
        ));
      } else {
        setState(() => _unmatched = result);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _sweep.stop();
      setState(() {
        _busy = false;
        _error = e;
      });
    } catch (e) {
      if (!mounted) return;
      _sweep.stop();
      setState(() {
        _busy = false;
        _error = ApiException(
            'Could not open the camera / gallery on this device. ($e)');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan number plate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _Viewfinder(bytes: _bytes, busy: _busy, sweep: _sweep),
          const SizedBox(height: 16),
          if (_busy)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5)),
                const SizedBox(width: 12),
                Text('Reading number plate…',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: const Text('Take photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              icon: Icons.error_outline_rounded,
              color: AppColors.bad,
              title: _error!.code == 'no_plate_detected'
                  ? "Couldn't find a plate"
                  : 'Something went wrong',
              body: _error!.message,
              child: const _ManualEntry(),
            ),
          ],
          if (_unmatched != null) ...[
            const SizedBox(height: 16),
            _UnmatchedCard(result: _unmatched!),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips for a perfect scan',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                for (final tip in const [
                  'Keep the whole plate inside the frame',
                  'Hold the phone level and about 1-2 m away',
                  'Avoid glare, shadows and motion blur',
                  'Use the gallery for an existing photo',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  const _ManualEntry();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Type the number instead',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        PlateSearchField(onSubmit: (p) => lookupAndOpen(context, p)),
      ],
    );
  }
}

class _UnmatchedCard extends StatelessWidget {
  const _UnmatchedCard({required this.result});
  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final others =
        result.candidates.where((c) => c != result.detectedPlate).toList();
    return _MessageCard(
      icon: Icons.search_off_rounded,
      color: AppColors.warn,
      title: 'Plate read, but not in our records',
      body:
          'We read the plate below. If it looks wrong, correct it and search again.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: NumberPlate(text: result.formattedPlate, height: 52),
            ),
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Other possible readings',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final c in others.take(3))
                  ActionChip(
                    label: Text(c),
                    onPressed: () => lookupAndOpen(context, c),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          PlateSearchField(
            initial: result.detectedPlate,
            onSubmit: (p) => lookupAndOpen(context, p),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body),
          child,
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.bytes,
    required this.busy,
    required this.sweep,
  });

  final Uint8List? bytes;
  final bool busy;
  final Animation<double> sweep;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, Color(0xFF16294A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (bytes != null)
              Image.memory(bytes!, fit: BoxFit.cover)
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.document_scanner_rounded,
                        size: 54, color: Colors.white54),
                    const SizedBox(height: 10),
                    Text('Point at a number plate',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            if (busy) Container(color: Colors.black.withAlpha(90)),
            CustomPaint(painter: _FramePainter()),
            if (busy)
              AnimatedBuilder(
                animation: sweep,
                builder: (context, _) => Align(
                  alignment: Alignment(0, -0.45 + sweep.value * 0.9),
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.amber.withAlpha(180),
                            blurRadius: 14,
                            spreadRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Amber corner brackets that show where the plate should sit.
class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
        size.width * 0.1, size.height * 0.28, size.width * 0.8, size.height * 0.44);
    final paint = Paint()
      ..color = AppColors.amber
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 30.0;

    void corner(Offset c, double dx, double dy) {
      canvas.drawLine(c, c + Offset(dx * len, 0), paint);
      canvas.drawLine(c, c + Offset(0, dy * len), paint);
    }

    corner(rect.topLeft, 1, 1);
    corner(rect.topRight, -1, 1);
    corner(rect.bottomLeft, 1, -1);
    corner(rect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
