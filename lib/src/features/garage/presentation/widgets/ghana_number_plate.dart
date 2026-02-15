import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GhanaNumberPlate extends StatelessWidget {
  final String plateNumber;
  final double height;
  final bool isSquare;

  const GhanaNumberPlate({
    super.key,
    required this.plateNumber,
    this.height = 70,
    this.isSquare = true,
  });

  @override
  Widget build(BuildContext context) {
    // Basic parsing logic to separate Prefix (GS) and Suffix (3493-13)
    final cleanPlate = plateNumber.toUpperCase().replaceAll(' ', '');
    final parts = cleanPlate.split('-');
    
    String prefix = '';
    String suffix = '';

    if (parts.isNotEmpty) {
      prefix = parts.first;
      if (parts.length > 1) {
        suffix = parts.sublist(1).join('-');
      }
    }
    
    // Fallback if parsing fails or formatted differently
    if (suffix.isEmpty && cleanPlate.length > 2) {
       final numericStart = cleanPlate.indexOf(RegExp(r'[0-9]'));
       if (numericStart > 0) {
         prefix = cleanPlate.substring(0, numericStart);
         suffix = cleanPlate.substring(numericStart);
       } else {
         suffix = cleanPlate;
       }
    }

    return Container(
      height: height,
      padding: EdgeInsets.all(height * 0.08),
      decoration: BoxDecoration(
        // High-end reflective metal look
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3F4F6),
            const Color(0xFFE5E7EB),
            const Color(0xFFD1D5DB),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.8), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          // Subtle inner highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 0,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // The Flag & GH in the top right
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGhanaFlag(height * 0.22),
                SizedBox(width: height * 0.05),
                Text(
                  'GH',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: height * 0.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          
          // Main text centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefix.isNotEmpty)
                  Text(
                    prefix,
                    style: GoogleFonts.outfit(
                      color: Colors.black.withValues(alpha: 0.9),
                      fontSize: height * 0.38,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                  ),
                if (suffix.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.02),
                    child: Text(
                      suffix,
                      style: GoogleFonts.outfit(
                        color: Colors.black.withValues(alpha: 0.9),
                        fontSize: height * 0.38,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhanaFlag(double height) {
    return Container(
      height: height,
      width: height * 1.5,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFCE1126))), // Red
          Expanded(
            child: Container(
              color: const Color(0xFFFCD116), // Yellow
              child: const Center(
                child: Icon(Icons.star, size: 4, color: Colors.black),
              ),
            ),
          ), 
          Expanded(child: Container(color: const Color(0xFF006B3F))), // Green
        ],
      ),
    );
  }
}
