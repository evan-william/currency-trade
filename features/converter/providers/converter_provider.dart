// FILE: lib/features/converter/providers/converter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_changer/features/converter/services/currency_api_service.dart';

// 1. State Object
class ConverterState {
  final String baseCurrency;
  final String targetCurrency;
  final String amount;
  final double? conversionResult;
  final bool isLoading;
  final String? errorMessage;
  // FIXED: Daftar mata uang diperluas menjadi 18 mata uang
  final List<String> currencies;
  // FIXED: Tambahkan field untuk melacak hasil konversi terakhir
  final String? lastConvertedBase;
  final String? lastConvertedTarget;

  ConverterState({
    this.baseCurrency = 'IDR',
    this.targetCurrency = 'USD',
    this.amount = '150000',
    this.conversionResult,
    this.isLoading = false,
    this.errorMessage,
    this.lastConvertedBase,
    this.lastConvertedTarget,
    this.currencies = const [
      'IDR', // Indonesian Rupiah
      'USD', // US Dollar
      'EUR', // Euro
      'GBP', // British Pound
      'JPY', // Japanese Yen
      'AUD', // Australian Dollar
      'CAD', // Canadian Dollar
      'CHF', // Swiss Franc
      'CNY', // Chinese Yuan
      'SGD', // Singapore Dollar
      'MYR', // Malaysian Ringgit
      'THB', // Thai Baht
      'KRW', // South Korean Won
      'INR', // Indian Rupee
      'NZD', // New Zealand Dollar
      'HKD', // Hong Kong Dollar
      'PHP', // Philippine Peso
      'VND', // Vietnamese Dong
    ],
  });

  ConverterState copyWith({
    String? baseCurrency,
    String? targetCurrency,
    String? amount,
    double? conversionResult,
    bool? isLoading,
    String? errorMessage,
    String? lastConvertedBase,
    String? lastConvertedTarget,
    bool clearResult = false,
  }) {
    return ConverterState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      amount: amount ?? this.amount,
      conversionResult: clearResult ? null : (conversionResult ?? this.conversionResult),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastConvertedBase: clearResult ? null : (lastConvertedBase ?? this.lastConvertedBase),
      lastConvertedTarget: clearResult ? null : (lastConvertedTarget ?? this.lastConvertedTarget),
      currencies: currencies,
    );
  }
}

// 2. State Notifier
class ConverterNotifier extends StateNotifier<ConverterState> {
  final CurrencyApiService _apiService;

  ConverterNotifier(this._apiService) : super(ConverterState());

  // FIXED: Hapus hasil saat mata uang berubah
  void setBaseCurrency(String currency) {
    state = state.copyWith(
      baseCurrency: currency,
      clearResult: true, // Hapus hasil konversi
    );
  }

  void setTargetCurrency(String currency) {
    state = state.copyWith(
      targetCurrency: currency,
      clearResult: true, // Hapus hasil konversi
    );
  }

  void setAmount(String amount) {
    state = state.copyWith(
      amount: amount,
      clearResult: true, // Hapus hasil konversi
    );
  }

  void swapCurrencies() {
    final base = state.baseCurrency;
    final target = state.targetCurrency;
    state = state.copyWith(
      baseCurrency: target,
      targetCurrency: base,
      clearResult: true, // Hapus hasil konversi
    );
  }

  // Fungsi utama untuk melakukan konversi
  Future<void> convert() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final double? amountToConvert = double.tryParse(state.amount);
    if (amountToConvert == null || amountToConvert <= 0) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Input jumlah tidak valid.',
      );
      return;
    }

    try {
      // Hubungi API
      final rates = await _apiService.getRates(state.baseCurrency);

      // Cari nilai tukar
      final exchangeRate = rates[state.targetCurrency];

      if (exchangeRate == null) {
        throw Exception('Mata uang tujuan tidak ditemukan di API.');
      }

      // Kalkulasi
      final result = amountToConvert * (exchangeRate as double);

      // FIXED: Simpan hasil beserta info mata uang yang dikonversi
      state = state.copyWith(
        isLoading: false,
        conversionResult: result,
        lastConvertedBase: state.baseCurrency,
        lastConvertedTarget: state.targetCurrency,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearResult: true,
      );
    }
  }
}

// 3. Provider (Global)
final converterProvider =
    StateNotifierProvider<ConverterNotifier, ConverterState>((ref) {
  final apiService = ref.watch(currencyApiProvider);
  return ConverterNotifier(apiService);
});