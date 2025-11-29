import 'package:flutter/material.dart';

class CurrencyCard extends StatelessWidget {
  final String title;
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onChanged;

  const CurrencyCard({
    super.key,
    required this.title,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // [FIXED] Mengganti withOpacity
            color: Colors.black.withAlpha((255 * 0.2).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedCurrency,
            onChanged: onChanged,
            items: currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            // [FIXED] Menambahkan const
            icon: const Icon(Icons.expand_more, color: Colors.tealAccent),
            dropdownColor: const Color(0xFF252525),
          ),
        ],
      ),
    );
  }
}