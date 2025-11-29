import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider untuk Dio
final dioProvider = Provider((ref) => Dio());

// 2. Provider untuk ApiService
final currencyApiProvider = Provider(
  (ref) => CurrencyApiService(ref.watch(dioProvider)),
);

class CurrencyApiService {
  final Dio _dio;
  // URL API dari dokumen konsep 
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/';

  CurrencyApiService(this._dio);

  // Fungsi untuk mengambil data nilai tukar
  Future<Map<String, dynamic>> getRates(String baseCurrency) async {
    try {
      // Mengirim permintaan HTTP GET
      final response = await _dio.get('$_baseUrl$baseCurrency');
      
      // Menerima balasan
      if (response.statusCode == 200) {
        // Mem-parsing data dan mengembalikan 'rates'
        return response.data['rates'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}