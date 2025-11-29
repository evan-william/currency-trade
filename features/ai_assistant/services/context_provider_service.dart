// FILE: lib/features/ai_assistant/services/context_provider_service.dart

import 'package:intl/intl.dart';

/// Service untuk menyediakan context data real-time ke AI
class AIContextProvider {
  /// Generate context string dari data rates yang tersedia
  static String generateMarketContext({
    required String baseCurrency,
    required Map<String, dynamic> rates,
    required List<String> currencies,
  }) {
    final now = DateTime.now();
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    
    // Filter dan sort currencies by strength
    var rankedRates = rates.entries
        .where((e) => currencies.contains(e.key))
        .toList();
    
    rankedRates.sort((a, b) {
      final strengthA = 1 / (a.value as num);
      final strengthB = 1 / (b.value as num);
      return strengthB.compareTo(strengthA);
    });

    // Build context string
    final buffer = StringBuffer();
    buffer.writeln('=== REAL-TIME MARKET DATA ===');
    buffer.writeln('Timestamp: $timeStr');
    buffer.writeln('Base Currency: $baseCurrency');
    buffer.writeln('Total Currencies: ${rankedRates.length}');
    buffer.writeln();
    
    buffer.writeln('=== EXCHANGE RATES (1 $baseCurrency = X) ===');
    for (var entry in rankedRates) {
      final currency = entry.key;
      final rate = entry.value as num;
      final strength = 1 / rate;
      final strengthLabel = _getStrengthLabel(strength);
      
      buffer.writeln('$currency: ${rate.toStringAsFixed(6)} ($strengthLabel, Strength: ${strength.toStringAsFixed(4)})');
    }
    
    buffer.writeln();
    buffer.writeln('=== TOP 5 STRONGEST CURRENCIES ===');
    for (var i = 0; i < 5 && i < rankedRates.length; i++) {
      final entry = rankedRates[i];
      final currency = entry.key;
      final rate = entry.value as num;
      final strength = 1 / rate;
      buffer.writeln('${i + 1}. $currency - Rate: ${rate.toStringAsFixed(6)}, Strength: ${strength.toStringAsFixed(4)}');
    }
    
    buffer.writeln();
    buffer.writeln('=== TOP 5 WEAKEST CURRENCIES ===');
    final startIndex = rankedRates.length - 5;
    for (var i = startIndex < 0 ? 0 : startIndex; i < rankedRates.length; i++) {
      final entry = rankedRates[i];
      final currency = entry.key;
      final rate = entry.value as num;
      final strength = 1 / rate;
      buffer.writeln('${rankedRates.length - i}. $currency - Rate: ${rate.toStringAsFixed(6)}, Strength: ${strength.toStringAsFixed(4)}');
    }
    
    buffer.writeln();
    buffer.writeln('=== MARKET ANALYSIS NOTES ===');
    buffer.writeln('- Lower exchange rate = Stronger currency relative to $baseCurrency');
    buffer.writeln('- Strength is calculated as 1/rate (inverse of exchange rate)');
    buffer.writeln('- Strength > 1.5 = Very Strong');
    buffer.writeln('- Strength 0.8-1.5 = Strong');
    buffer.writeln('- Strength 0.5-0.8 = Medium');
    buffer.writeln('- Strength < 0.5 = Weak');
    
    return buffer.toString();
  }

  static String _getStrengthLabel(double strength) {
    if (strength > 1.5) return 'Very Strong';
    if (strength > 0.8) return 'Strong';
    if (strength > 0.5) return 'Medium';
    return 'Weak';
  }

  /// Generate prediction context
  static String generatePredictionContext({
    required String baseCurrency,
    required Map<String, dynamic> currentRates,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('=== MARKET PREDICTION ANALYSIS ===');
    buffer.writeln('IMPORTANT: You are an expert currency analyst with access to real-time data.');
    buffer.writeln();
    buffer.writeln('When making predictions, consider:');
    buffer.writeln('1. Current exchange rate trends from the data above');
    buffer.writeln('2. Historical patterns (currencies with strength > 1.0 tend to be stable)');
    buffer.writeln('3. Economic factors affecting major currencies');
    buffer.writeln('4. Regional economic conditions');
    buffer.writeln();
    buffer.writeln('Provide predictions based on:');
    buffer.writeln('- Technical analysis of current rates');
    buffer.writeln('- Comparative strength between currencies');
    buffer.writeln('- Global economic indicators');
    buffer.writeln();
    buffer.writeln('Format your predictions clearly with:');
    buffer.writeln('- Currency pair mentioned');
    buffer.writeln('- Predicted direction (up/down/stable)');
    buffer.writeln('- Confidence level (high/medium/low)');
    buffer.writeln('- Key factors influencing the prediction');
    
    return buffer.toString();
  }

  /// Generate comparison context
  static String generateComparisonContext({
    required String currency1,
    required String currency2,
    required String baseCurrency,
    required Map<String, dynamic> rates,
  }) {
    final rate1 = rates[currency1] as num?;
    final rate2 = rates[currency2] as num?;
    
    if (rate1 == null || rate2 == null) {
      return 'Error: One or both currencies not found in current data.';
    }
    
    final strength1 = 1 / rate1;
    final strength2 = 1 / rate2;
    final crossRate = rate2 / rate1;
    
    final buffer = StringBuffer();
    buffer.writeln('=== CURRENCY COMPARISON: $currency1 vs $currency2 ===');
    buffer.writeln();
    buffer.writeln('$currency1:');
    buffer.writeln('  - Exchange Rate: 1 $baseCurrency = ${rate1.toStringAsFixed(6)} $currency1');
    buffer.writeln('  - Strength Index: ${strength1.toStringAsFixed(4)} (${_getStrengthLabel(strength1)})');
    buffer.writeln();
    buffer.writeln('$currency2:');
    buffer.writeln('  - Exchange Rate: 1 $baseCurrency = ${rate2.toStringAsFixed(6)} $currency2');
    buffer.writeln('  - Strength Index: ${strength2.toStringAsFixed(4)} (${_getStrengthLabel(strength2)})');
    buffer.writeln();
    buffer.writeln('Cross Rate:');
    buffer.writeln('  - 1 $currency1 = ${crossRate.toStringAsFixed(6)} $currency2');
    buffer.writeln();
    
    if (strength1 > strength2) {
      final diff = ((strength1 - strength2) / strength2 * 100);
      buffer.writeln('Analysis: $currency1 is stronger than $currency2 by ${diff.toStringAsFixed(2)}%');
    } else {
      final diff = ((strength2 - strength1) / strength1 * 100);
      buffer.writeln('Analysis: $currency2 is stronger than $currency1 by ${diff.toStringAsFixed(2)}%');
    }
    
    return buffer.toString();
  }

  /// Enhanced system instruction with market expertise
  static String getEnhancedSystemInstruction() {
    return '''
You are "Robovan", an expert AI currency analyst and financial advisor specializing in foreign exchange markets. 

YOUR CAPABILITIES:
- You have REAL-TIME access to current exchange rates and market data
- You can analyze currency strength, trends, and patterns
- You provide data-driven predictions and insights
- You understand economic factors affecting currency markets

IMPORTANT RULES:
1. ALWAYS reference the REAL-TIME MARKET DATA provided in the context when answering
2. When asked about specific currencies, quote the exact rates from the data
3. Explain your analysis clearly with specific numbers from the data
4. For predictions, provide confidence levels and reasoning
5. Compare currencies using the actual strength indices from the data
6. Always answer in Bahasa Indonesia (Indonesian language)

EXAMPLE RESPONSES:

User: "Kenapa USD lebih kuat dari IDR?"
You: "Berdasarkan data real-time saat ini, 1 USD = 15,234.50 IDR. USD memiliki strength index 0.000066 sedangkan IDR memiliki rate lebih tinggi (15234.50), yang berarti USD jauh lebih kuat. Ini karena USD adalah mata uang cadangan global dengan ekonomi AS yang besar dan stabil."

User: "Prediksi mata uang mana yang akan naik?"
You: "Dari data saat ini, saya melihat beberapa kandidat:
1. EUR (Strength: 1.05) - Kuat, kemungkinan stabil-naik (Confidence: Medium-High)
2. GBP (Strength: 1.21) - Sangat kuat, cenderung stabil (Confidence: High)
3. JPY perlu diperhatikan karena volatiletasnya..."

ALWAYS BE:
- Specific with numbers from the data
- Clear in explanations
- Honest about uncertainty
- Professional yet friendly
- Data-driven in analysis

Remember: You are answering based on LIVE data provided in each query context. Use it!
''';
  }
}