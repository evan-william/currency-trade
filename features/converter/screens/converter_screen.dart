// FILE: lib/features/converter/screens/converter_screen.dart
// 🚀 ULTRA PROFESSIONAL CONVERTER - Bloomberg Terminal Style!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_changer/features/ai_assistant/screens/chat_screen.dart';
import 'package:currency_changer/features/ai_assistant/services/gemini_service.dart';
import 'package:currency_changer/features/converter/providers/converter_provider.dart';
import 'package:currency_changer/features/converter/services/currency_api_service.dart';
import 'package:currency_changer/features/converter/widgets/currency_card.dart';
import 'package:currency_changer/features/converter/widgets/result_display.dart';
import 'package:currency_changer/features/market/widgets/live_rate_table.dart';
import 'package:currency_changer/features/market/widgets/market_dashboard_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  bool _isLoadingRates = false;
  Map<String, dynamic>? _currentRates;
  String _selectedBaseCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadInitialRates();
  }

  Future<void> _loadInitialRates() async {
    setState(() => _isLoadingRates = true);
    try {
      final apiService = ref.read(currencyApiProvider);
      final rates = await apiService.getRates(_selectedBaseCurrency);
      if (mounted) {
        setState(() {
          _currentRates = rates;
          _isLoadingRates = false;
        });
        _updateAIContext();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRates = false);
      }
    }
  }

  void _updateAIContext() {
    if (_currentRates != null) {
      try {
        final state = ref.read(converterProvider);
        ref.read(geminiServiceProvider).updateMarketContext(
          baseCurrency: _selectedBaseCurrency,
          rates: _currentRates!,
          currencies: state.currencies,
        );
        debugPrint('✅ AI context updated with latest market data');
      } catch (e) {
        debugPrint('⚠️ Failed to update AI context: $e');
      }
    }
  }

  Future<void> _refreshRates() async {
    await _loadInitialRates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MARKET DATA UPDATED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All rates and AI context refreshed',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00FF88), width: 2),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFF0), Color(0xFF00D4FF)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFF0).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.currency_exchange_rounded, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENCY TERMINAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Professional Trading Platform',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Refresh Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF88).withValues(alpha: 0.2),
                  const Color(0xFF00FF88).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FF88).withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              icon: _isLoadingRates
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00FF88),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF00FF88)),
              onPressed: _isLoadingRates ? null : _refreshRates,
              tooltip: 'Refresh Market Data',
            ),
          ),
          
          // AI Chat Button
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.tealAccent.withValues(alpha: 0.2),
                      Colors.tealAccent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.tealAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.psychology_rounded, color: Colors.tealAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  tooltip: 'AI Assistant',
                ),
              ),
              if (_currentRates != null)
                Positioned(
                  right: 16,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00FF88), Color(0xFF00FFF0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .fadeOut(duration: 1000.ms)
                      .then()
                      .fadeIn(duration: 1000.ms),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRates,
        color: const Color(0xFF00FFF0),
        backgroundColor: const Color(0xFF1A1A2E),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎯 MARKET STATUS BANNER
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FF88).withValues(alpha: 0.2),
                      const Color(0xFF00FFF0).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00FFF0)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .fadeOut(duration: 1000.ms)
                        .then()
                        .fadeIn(duration: 1000.ms),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MARKETS OPEN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Color(0xFF00FF88),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-time data • AI-powered insights',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.trending_up_rounded, color: Color(0xFF00FF88), size: 24),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),

              // SECTION 1: LIVE EXCHANGE RATE TABLE
              if (_isLoadingRates)
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A0E27), Color(0xFF1A1A2E)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF00FFF0),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'LOADING MARKET DATA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Fetching real-time rates...',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_currentRates != null)
                Column(
                  children: [
                    // Base Currency Selector with Premium Design
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1A1A2E),
                            const Color(0xFF0F1729).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        border: Border.all(
                          color: Colors.tealAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.public, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BASE CURRENCY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Select reference currency',
                                  style: TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.tealAccent.withValues(alpha: 0.2),
                                  Colors.blueAccent.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.tealAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedBaseCurrency,
                              underline: const SizedBox.shrink(),
                              dropdownColor: const Color(0xFF1A1A2E),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              items: state.currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(
                                    currency,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newBase) async {
                                if (newBase != null) {
                                  setState(() {
                                    _selectedBaseCurrency = newBase;
                                    _isLoadingRates = true;
                                  });
                                  try {
                                    final apiService = ref.read(currencyApiProvider);
                                    final rates = await apiService.getRates(newBase);
                                    if (mounted) {
                                      setState(() {
                                        _currentRates = rates;
                                        _isLoadingRates = false;
                                      });
                                      _updateAIContext();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setState(() => _isLoadingRates = false);
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Live Rate Table
                    LiveRateTableEnhanced(
                      baseCurrency: _selectedBaseCurrency,
                      rates: _currentRates!,
                      currencies: state.currencies,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.05, duration: 400.ms),

              // SECTION 2: MARKET DASHBOARD CHART
              if (_currentRates != null)
                MarketDashboardChartEnhanced(
                  baseCurrency: _selectedBaseCurrency,
                  rates: _currentRates!,
                  currencies: state.currencies,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.05, duration: 400.ms),

              // SECTION 3: CURRENCY CONVERTER - PREMIUM DESIGN
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A0E27), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.tealAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF00FF), Color(0xFF00FFF0)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF00FF).withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calculate_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENCY CONVERTER',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Instant conversion calculator',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Currency Cards
                    CurrencyCard(
                      title: 'FROM CURRENCY',
                      selectedCurrency: state.baseCurrency,
                      currencies: state.currencies,
                      onChanged: (val) {
                        if (val != null) notifier.setBaseCurrency(val);
                      },
                    ).animate().slideX(begin: -0.2, duration: 400.ms),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FFF0), Color(0xFF00D4FF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFF0).withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.swap_vert_rounded, color: Colors.black, size: 28),
                            onPressed: notifier.swapCurrencies,
                          ),
                        ).animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 3000.ms, color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),

                    CurrencyCard(
                      title: 'TO CURRENCY',
                      selectedCurrency: state.targetCurrency,
                      currencies: state.currencies,
                      onChanged: (val) {
                        if (val != null) notifier.setTargetCurrency(val);
                      },
                    ).animate().slideX(begin: 0.2, duration: 400.ms),

                    const SizedBox(height: 28),

                    // Amount Input
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.tealAccent.withValues(alpha: 0.3),
                            Colors.blueAccent.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextFormField(
                        initialValue: state.amount,
                        decoration: InputDecoration(
                          labelText: 'AMOUNT TO CONVERT',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.tealAccent),
                          filled: true,
                          fillColor: const Color(0xFF1A1A2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        onChanged: notifier.setAmount,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 32),

                    // Convert Button
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFF0), Color(0xFF00D4FF)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFF0).withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : notifier.convert,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bolt, color: Colors.black, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'CONVERT NOW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 3000.ms, color: Colors.white.withValues(alpha: 0.3)),

                    const SizedBox(height: 28),

                    // Error Display
                    if (state.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF4444).withValues(alpha: 0.2),
                              const Color(0xFFFF4444).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFF4444).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFFF4444), size: 24),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ERROR',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF4444),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFFF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 400.ms),

                    // Result Display
                    if (state.conversionResult != null &&
                        state.lastConvertedBase != null &&
                        state.lastConvertedTarget != null)
                      ResultDisplay(
                        baseAmount: double.tryParse(state.amount) ?? 0,
                        baseCurrency: state.lastConvertedBase!,
                        targetAmount: state.conversionResult!,
                        targetCurrency: state.lastConvertedTarget!,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}