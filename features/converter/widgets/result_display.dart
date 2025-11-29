// FILE: lib/features/converter/widgets/result_display.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultDisplay extends StatelessWidget {
  final double baseAmount;
  final String baseCurrency;
  final double targetAmount;
  final String targetCurrency;

  const ResultDisplay({
    super.key,
    required this.baseAmount,
    required this.baseCurrency,
    required this.targetAmount,
    required this.targetCurrency,
  });

  // Helper untuk format angka
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        // FIXED: withOpacity -> withValues
        border: Border.all(
          color: Colors.tealAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.tealAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hasil Konversi',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tampilan jumlah asal
          Text(
            '${_formatCurrency(baseAmount)} $baseCurrency',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Icon arrow
          const Icon(
            Icons.arrow_downward_rounded,
            color: Colors.tealAccent,
            size: 28,
          ),
          const SizedBox(height: 12),
          
          // Tampilan hasil konversi 
          Text(
            '${_formatCurrency(targetAmount)} $targetCurrency',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.tealAccent,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info exchange rate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1 $baseCurrency = ${_formatCurrency(targetAmount / baseAmount)} $targetCurrency',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack);
  }
}