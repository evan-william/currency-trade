// FILE: lib/features/market/widgets/market_dashboard_chart.dart - PART A
// 🚀 PROFESSIONAL TRADING CHART - FIXED VERSION!
// ✅ Area Chart sekarang beda dari Line Chart (full gradient fill)
// ✅ Grid, Volume, Expand buttons sekarang WORKING!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

enum ChartTimeRange {
  day7('7D', 7, 7),
  day30('1M', 30, 15),
  day90('3M', 90, 30),
  year1('1Y', 365, 52),
  all('ALL', 999, 100);

  final String label;
  final int days;
  final int dataPoints;
  const ChartTimeRange(this.label, this.days, this.dataPoints);
}

enum ChartType {
  line('Line', Icons.show_chart),
  candle('Candle', Icons.candlestick_chart),
  area('Area', Icons.area_chart);

  final String label;
  final IconData icon;
  const ChartType(this.label, this.icon);
}

class MarketDashboardChartEnhanced extends ConsumerStatefulWidget {
  final String baseCurrency;
  final Map<String, dynamic> rates;
  final List<String> currencies;

  const MarketDashboardChartEnhanced({
    super.key,
    required this.baseCurrency,
    required this.rates,
    required this.currencies,
  });

  @override
  ConsumerState<MarketDashboardChartEnhanced> createState() => _MarketDashboardChartEnhancedState();
}

class _MarketDashboardChartEnhancedState extends ConsumerState<MarketDashboardChartEnhanced> {
  ChartTimeRange _selectedRange = ChartTimeRange.day30;
  ChartType _chartType = ChartType.line;
  String? _selectedCurrency;
  List<String> _comparisonCurrencies = [];
  bool _showGrid = true; // ✅ Sekarang dipakai!
  bool _showVolume = false; // ✅ Sekarang dipakai!

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currencies.first;
  }

  // Generate realistic historical data with volatility
  List<FlSpot> _generateHistoricalData(String currency, ChartTimeRange range) {
    final currentRate = (widget.rates[currency] as num?)?.toDouble() ?? 1.0;
    final points = <FlSpot>[];
    final random = math.Random(currency.hashCode);
    
    double price = currentRate;
    double trend = (random.nextDouble() - 0.5) * 0.02;
    
    for (int i = 0; i < range.dataPoints; i++) {
      final volatility = random.nextGaussian() * currentRate * 0.03;
      final meanReversion = (currentRate - price) * 0.1;
      price += volatility + meanReversion + trend * currentRate;
      price = price.clamp(currentRate * 0.7, currentRate * 1.3);
      
      points.add(FlSpot(i.toDouble(), price));
    }
    
    return points;
  }

  // Generate volume data (simulated trading volume)
  List<FlSpot> _generateVolumeData(String currency, ChartTimeRange range) {
    final points = <FlSpot>[];
    final random = math.Random(currency.hashCode + 999);
    
    for (int i = 0; i < range.dataPoints; i++) {
      final baseVolume = 1000000.0;
      final volatility = random.nextDouble() * 0.5;
      final volume = baseVolume * (0.5 + volatility);
      points.add(FlSpot(i.toDouble(), volume));
    }
    
    return points;
  }

  // Generate candlestick data
  List<CandleData> _generateCandleData(String currency, ChartTimeRange range) {
    final spots = _generateHistoricalData(currency, range);
    final candles = <CandleData>[];
    
    for (int i = 0; i < spots.length; i++) {
      final close = spots[i].y;
      final open = i > 0 ? spots[i - 1].y : close;
      final volatility = close * 0.02;
      final high = math.max(open, close) + volatility;
      final low = math.min(open, close) - volatility;
      
      candles.add(CandleData(
        x: i.toDouble(),
        open: open,
        high: high,
        low: low,
        close: close,
      ));
    }
    
    return candles;
  }

  Color _getCurrencyColor(int index) {
    final colors = [
      const Color(0xFF00FFF0),
      const Color(0xFFFF4444),
      const Color(0xFF00FF88),
      const Color(0xFFFFA500),
      const Color(0xFFFF00FF),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 ULTRA PREMIUM HEADER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.tealAccent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF00FF), Color(0xFF00FFF0)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF00FF).withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.candlestick_chart_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'MARKET TRENDS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF00FF), Color(0xFF00FFF0)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ADVANCED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Professional trading analytics',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Chart Type Selector
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: ChartType.values.map((type) {
                      final isSelected = _chartType == type;
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _chartType = type),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF00FF), Color(0xFF00FFF0)],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 18,
                                  color: isSelected ? Colors.black : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Currency Selector & Time Range
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              border: Border(
                bottom: BorderSide(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Currency Selector
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, size: 20, color: Colors.tealAccent),
                    const SizedBox(width: 12),
                    const Text(
                      'TRACKING:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
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
                          value: _selectedCurrency,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          dropdownColor: const Color(0xFF1A1A2E),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                          items: widget.currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(
                                '$currency / ${widget.baseCurrency}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCurrency = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Time Range Selector
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E27),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ChartTimeRange.values.map((range) {
                      final isSelected = _selectedRange == range;
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRange = range),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF00FFF0), Color(0xFF00D4FF)],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              range.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.black : Colors.grey,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 🚀 MAIN CHART AREA
          Container(
            height: _showVolume ? 500 : 400, // ✅ Tinggi berubah kalau volume aktif!
            padding: const EdgeInsets.all(24),
            child: _buildChart(),
          ).animate().fadeIn(duration: 600.ms), 

// 📊 STATISTICS CARDS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('HIGH', _getHigh(), const Color(0xFF00FF88), Icons.arrow_upward)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('LOW', _getLow(), const Color(0xFFFF4444), Icons.arrow_downward)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('AVG', _getAverage(), Colors.tealAccent, Icons.show_chart)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('VOLATILITY', _getVolatility(), const Color(0xFFFFA500), Icons.waves)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🎯 CHART CONTROLS - ✅ SEKARANG WORKING!
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F3460).withValues(alpha: 0.8),
                  const Color(0xFF16213E).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildControlButton(
                      Icons.grid_on,
                      'Grid',
                      _showGrid,
                      () => setState(() => _showGrid = !_showGrid), // ✅ WORKING!
                    ),
                    _buildControlButton(
                      Icons.bar_chart,
                      'Volume',
                      _showVolume,
                      () => setState(() => _showVolume = !_showVolume), // ✅ WORKING!
                    ),
                    _buildControlButton(
                      Icons.fullscreen,
                      'Expand',
                      false,
                      () => _showFullscreenChart(context), // ✅ WORKING!
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.tealAccent),
                      const SizedBox(width: 8),
                      Text(
                        '💹 Simulated historical data • Base: ${widget.baseCurrency}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // ✅ BUILD CHART - Sekarang grid & volume bekerja!
  Widget _buildChart() {
    if (_selectedCurrency == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Main Chart
        Expanded(
          flex: _showVolume ? 7 : 10,
          child: _buildMainChart(),
        ),
        
        // Volume Chart (kalau aktif)
        if (_showVolume) ...[
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: _buildVolumeChart(),
          ),
        ],
      ],
    );
  }

  Widget _buildMainChart() {
    switch (_chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.candle:
        return _buildCandleChart();
      case ChartType.area:
        return _buildAreaChart(); // ✅ Sekarang BEDA dari line!
    }
  }

  // ✅ LINE CHART - Dengan grid yang bisa toggle
  Widget _buildLineChart() {
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: _showGrid, // ✅ Toggle grid!
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.tealAccent.withValues(alpha: 0.1),
              strokeWidth: 1,
              dashArray: [8, 4],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.tealAccent.withValues(alpha: 0.1),
              strokeWidth: 1,
              dashArray: [8, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatRate(value),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: data.length / 6,
              getTitlesWidget: (value, meta) {
                if (value == data.length - 1) {
                  return const Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.tealAccent.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.tealAccent.withValues(alpha: 0.3)),
          ),
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            curveSmoothness: 0.4,
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFF0), Color(0xFF00FF88)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length < 50,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF00FFF0),
                );
              },
            ),
            belowBarData: BarAreaData(show: false), // ✅ Line = NO FILL
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${_formatRate(spot.y)}\nPoint ${spot.x.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ✅ AREA CHART - FULL GRADIENT FILL (BEDA dari line!)
  Widget _buildAreaChart() {
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: _showGrid,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.tealAccent.withValues(alpha: 0.1),
              strokeWidth: 1,
              dashArray: [8, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatRate(value),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: data.length / 6,
              getTitlesWidget: (value, meta) {
                if (value == data.length - 1) {
                  return const Text('Now', style: TextStyle(fontSize: 11, color: Colors.tealAccent, fontWeight: FontWeight.bold));
                }
                return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.tealAccent.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.tealAccent.withValues(alpha: 0.3)),
          ),
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            curveSmoothness: 0.5, // ✅ Lebih smooth untuk area
            gradient: const LinearGradient(
              colors: [Color(0xFFFF00FF), Color(0xFF00FFF0)], // ✅ Warna beda!
            ),
            barWidth: 2, // ✅ Lebih tipis
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // ✅ No dots untuk area
            belowBarData: BarAreaData(
              show: true, // ✅ FULL FILL! Ini yang bikin beda!
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF00FF).withValues(alpha: 0.5), // ✅ Heavy fill top
                  const Color(0xFF00FFF0).withValues(alpha: 0.3),
                  const Color(0xFF00FFF0).withValues(alpha: 0.1),
                  Colors.transparent, // ✅ Fade ke transparent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${_formatRate(spot.y)}\nPoint ${spot.x.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ✅ VOLUME CHART - Ditampilkan di bawah main chart
  Widget _buildVolumeChart() {
    final volumeData = _generateVolumeData(_selectedCurrency!, _selectedRange);
    final maxVolume = volumeData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        minX: 0,
        maxX: volumeData.length.toDouble() - 1,
        minY: 0,
        maxY: maxVolume * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: volumeData,
            isCurved: false,
            color: Colors.grey,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandleChart() {
    final candles = _generateCandleData(_selectedCurrency!, _selectedRange);
    
    return CustomPaint(
      painter: CandlestickPainter(
        candles: candles,
        showGrid: _showGrid, // ✅ Grid toggle!
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildStatCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRate(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF00FFF0), Color(0xFF00D4FF)],
                )
              : null,
          color: isActive ? null : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.tealAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FULLSCREEN CHART DIALOG
  void _showFullscreenChart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A0E27), Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'FULLSCREEN CHART',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.tealAccent,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildMainChart(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getHigh() {
    if (_selectedCurrency == null) return 0;
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    return data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  }

  double _getLow() {
    if (_selectedCurrency == null) return 0;
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    return data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
  }

  double _getAverage() {
    if (_selectedCurrency == null) return 0;
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    return data.map((e) => e.y).reduce((a, b) => a + b) / data.length;
  }

  double _getVolatility() {
    if (_selectedCurrency == null) return 0;
    final data = _generateHistoricalData(_selectedCurrency!, _selectedRange);
    final avg = _getAverage();
    final variance = data.map((e) => math.pow(e.y - avg, 2)).reduce((a, b) => a + b) / data.length;
    return math.sqrt(variance);
  }

  String _formatRate(double rate) {
    if (rate >= 10000) {
      return NumberFormat('#,##0').format(rate);
    } else if (rate >= 1) {
      return NumberFormat('0.00').format(rate);
    } else {
      return NumberFormat('0.0000').format(rate);
    }
  }
}

// Custom Painter for Candlestick Chart
class CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final bool showGrid;

  CandlestickPainter({required this.candles, required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;
    final candleWidth = (size.width / candles.length) * 0.7;

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.tealAccent.withValues(alpha: 0.1)
        ..strokeWidth = 1;

      for (int i = 0; i <= 5; i++) {
        final y = size.height * i / 5;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Draw candles
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = (size.width / candles.length) * (i + 0.5);
      
      final openY = size.height - ((candle.open - minPrice) / priceRange * size.height);
      final closeY = size.height - ((candle.close - minPrice) / priceRange * size.height);
      final highY = size.height - ((candle.high - minPrice) / priceRange * size.height);
      final lowY = size.height - ((candle.low - minPrice) / priceRange * size.height);
      
      final isGreen = candle.close >= candle.open;
      final color = isGreen ? const Color(0xFF00FF88) : const Color(0xFFFF4444);
      
      // Draw wick
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);
      
      // Draw body
      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final bodyRect = Rect.fromLTRB(
        x - candleWidth / 2,
        math.min(openY, closeY),
        x + candleWidth / 2,
        math.max(openY, closeY),
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
        bodyPaint,
      );
      
      // Draw outline
      final outlinePaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CandleData {
  final double x;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

// Extension for Gaussian random
extension RandomGaussian on math.Random {
  double nextGaussian() {
    double u1 = nextDouble();
    double u2 = nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }
}