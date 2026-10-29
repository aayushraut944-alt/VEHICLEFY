import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text box for typing a registration number manually.
class PlateSearchField extends StatefulWidget {
  const PlateSearchField({
    super.key,
    required this.onSubmit,
    this.initial = '',
    this.hint = 'Enter number, e.g. MH12AB1234',
  });

  final ValueChanged<String> onSubmit;
  final String initial;
  final String hint;

  @override
  State<PlateSearchField> createState() => _PlateSearchFieldState();
}

class _PlateSearchFieldState extends State<PlateSearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go([String? _]) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.search,
      onSubmitted: _go,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 \-]')),
        LengthLimitingTextInputFormatter(14),
      ],
      style: const TextStyle(
          fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
            fontWeight: FontWeight.w500, letterSpacing: 0, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: _go,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
