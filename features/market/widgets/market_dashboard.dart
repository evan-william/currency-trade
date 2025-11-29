// FILE: lib/features/market/widgets/market_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MarketDashboard extends ConsumerStatefulWidget {
  final String baseCurrency;
  final Map<String, dynamic> rates;
  final List<String> currencies;

  const MarketDashboard({
    super.key,
    required this.baseCurrency,
    required this.rates,
    required this.currencies,
  });

  @override
  ConsumerState<MarketDashboard> createState() => _MarketDashboardState();
}

class _MarketDashboardState extends ConsumerState<MarketDashboard> {
  String _formatRate(double rate) {
    if (rate >= 1000) {
      return NumberFormat.compact().format(rate);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(2);
    } else {
      return rate.toStringAsFixed(4);
    }
  }

  Color _getStrengthColor(double strength) {
    if (strength > 1.5) return Colors.green;
    if (strength > 0.8) return Colors.tealAccent;
    if (strength > 0.5) return Colors.orange;
    return Colors.red;
  }

  List<MapEntry<String, dynamic>> get rankedCurrencies {
    var entries = widget.rates.entries
        .where((e) => widget.currencies.contains(e.key))
        .toList();

    entries.sort((a, b) {
      final strengthA = 1 / (a.value as num);
      final strengthB = 1 / (b.value as num);
      return strengthB.compareTo(strengthA);
    });

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final ranked = rankedCurrencies;
    final strongestCurrency = ranked.first;
    final weakestCurrency = ranked.last;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E1E),
            Colors.tealAccent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.tealAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.tealAccent, Colors.teal],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Market Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time currency strength ranking',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top 3 & Bottom 3 Quick View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildHighlightCard(
                    'Strongest',
                    strongestCurrency.key,
                    1 / (strongestCurrency.value as num),
                    Icons.arrow_upward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightCard(
                    'Weakest',
                    weakestCurrency.key,
                    1 / (weakestCurrency.value as num),
                    Icons.arrow_downward,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Strength Ranking Chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Currency Strength Ranking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bar Chart
          Container(
            height: 400,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: ranked.length,
              itemBuilder: (context, index) {
                final entry = ranked[index];
                final currency = entry.key;
                final rate = entry.value as num;
                final strength = 1 / rate;
                final maxStrength = 1 / (ranked.last.value as num);
                final percentage = (strength / maxStrength).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _getStrengthColor(strength).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getStrengthColor(strength),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                currency,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatRate(rate.toDouble())} ${widget.baseCurrency}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              // fontFeatureSettings removed for compatibility
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            height: 32,
                            width: MediaQuery.of(context).size.width * percentage * 0.85,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getStrengthColor(strength),
                                  _getStrengthColor(strength).withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStrengthColor(strength).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(percentage * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 50))
                    .slideX(begin: -0.2, duration: 400.ms);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Footer Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Strength calculated as 1/${widget.baseCurrency} rate • Higher is stronger',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    String label,
    String currency,
    num strength,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currency,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Strength: ${strength.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    ).animate()
        .scale(duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}