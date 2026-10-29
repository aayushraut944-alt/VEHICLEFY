import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An Indian-style licence plate: white = private, yellow = commercial, green = electric.
class NumberPlate extends StatelessWidget {
  const NumberPlate({
    super.key,
    required this.text,
    this.color = 'white',
    this.height = 56,
  });

  final String text;
  final String color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (color) {
      case 'yellow':
        bg = const Color(0xFFFFC928);
        fg = const Color(0xFF111111);
        break;
      case 'green':
        bg = const Color(0xFF1E9E5A);
        fg = Colors.white;
        break;
      default:
        bg = Colors.white;
        fg = const Color(0xFF111111);
    }

    final radius = BorderRadius.circular(height * 0.16);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF111111), width: height * 0.045),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // blue "IND" strip
            Container(
              width: height * 0.42,
              height: double.infinity,
              color: const Color(0xFF0A3D91),
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'IND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.3),
              child: Text(
                text,
                maxLines: 1,
                style: GoogleFonts.oswald(
                  color: fg,
                  fontSize: height * 0.64,
                  fontWeight: FontWeight.w700,
                  letterSpacing: height * 0.04,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
