// FILE: lib/features/ai_assistant/services/gemini_service.dart
// ✅ REAL FIX: Masalahnya BUKAN rate limit, tapi error handling yang salah!

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:currency_changer/features/ai_assistant/services/context_provider_service.dart';

// 1. Model Chat
class ChatMessage {
  final String text;
  final bool isFromUser;
  ChatMessage(this.text, {this.isFromUser = true});
}

// 2. Model Category Enum
enum ModelCategory {
  chat,
  experimental,
  embedding,
  image,
  video,
  audio,
  other
}

// 3. Model Info Class
class ModelInfo {
  final String name;
  final String displayName;
  final ModelCategory category;
  final String description;

  ModelInfo({
    required this.name,
    required this.displayName,
    required this.category,
    required this.description,
  });
}

// 4. Service Logic
class GeminiService {
  final SharedPreferences prefs;
  GenerativeModel? _model;
  ChatSession? _chat;
  String? _currentModelName;
  
  // Context awareness
  String? _currentMarketContext;
  String? _currentBaseCurrency;
  Map<String, dynamic>? _currentRates;

  GeminiService(this.prefs);

  String? get currentModelName => _currentModelName;

  void updateMarketContext({
    required String baseCurrency,
    required Map<String, dynamic> rates,
    required List<String> currencies,
  }) {
    _currentBaseCurrency = baseCurrency;
    _currentRates = rates;
    _currentMarketContext = AIContextProvider.generateMarketContext(
      baseCurrency: baseCurrency,
      rates: rates,
      currencies: currencies,
    );
    debugPrint('📊 Market context updated for base: $baseCurrency');
  }

  List<ModelInfo> getAllModels() {
    return [
      // ✅ SEMUA MODEL YANG WORKING DARI TEST!
      
      // GEMINI 2.5 (Recommended)
      ModelInfo(
        name: 'gemini-2.5-flash',
        displayName: 'Gemini 2.5 Flash (Recommended)',
        category: ModelCategory.chat,
        description: 'Stabil & cepat, versi terbaru',
      ),
      ModelInfo(
        name: 'gemini-2.5-pro',
        displayName: 'Gemini 2.5 Pro',
        category: ModelCategory.chat,
        description: 'Paling pintar, agak lambat',
      ),
      ModelInfo(
        name: 'gemini-2.5-flash-lite',
        displayName: 'Gemini 2.5 Flash Lite',
        category: ModelCategory.chat,
        description: 'Super cepat & hemat',
      ),
      
      // GEMINI 2.0
      ModelInfo(
        name: 'gemini-2.0-flash',
        displayName: 'Gemini 2.0 Flash',
        category: ModelCategory.chat,
        description: 'Versi stabil 2.0',
      ),
      ModelInfo(
        name: 'gemini-2.0-flash-001',
        displayName: 'Gemini 2.0 Flash 001',
        category: ModelCategory.chat,
        description: 'Versi snapshot stabil',
      ),
      ModelInfo(
        name: 'gemini-2.0-flash-lite',
        displayName: 'Gemini 2.0 Flash Lite',
        category: ModelCategory.chat,
        description: 'Lite version 2.0',
      ),
      ModelInfo(
        name: 'gemini-2.0-flash-lite-001',
        displayName: 'Gemini 2.0 Flash Lite 001',
        category: ModelCategory.chat,
        description: 'Lite snapshot',
      ),
      
      // LATEST (Auto update)
      ModelInfo(
        name: 'gemini-flash-latest',
        displayName: 'Gemini Flash Latest',
        category: ModelCategory.chat,
        description: 'Selalu update ke versi terbaru',
      ),
      ModelInfo(
        name: 'gemini-pro-latest',
        displayName: 'Gemini Pro Latest',
        category: ModelCategory.chat,
        description: 'Pro terbaru',
      ),
      ModelInfo(
        name: 'gemini-flash-lite-latest',
        displayName: 'Gemini Flash Lite Latest',
        category: ModelCategory.chat,
        description: 'Lite terbaru',
      ),
      
      // PREVIEW (Experimental tapi working)
      ModelInfo(
        name: 'gemini-2.5-flash-preview-09-2025',
        displayName: 'Gemini 2.5 Flash Preview Sep 2025',
        category: ModelCategory.experimental,
        description: 'Preview terbaru',
      ),
      ModelInfo(
        name: 'gemini-2.5-flash-lite-preview-09-2025',
        displayName: 'Gemini 2.5 Flash Lite Preview Sep 2025',
        category: ModelCategory.experimental,
        description: 'Lite preview',
      ),
      ModelInfo(
        name: 'gemini-2.0-flash-lite-preview',
        displayName: 'Gemini 2.0 Flash Lite Preview',
        category: ModelCategory.experimental,
        description: '2.0 lite preview',
      ),
      
      // GEMMA (Open source, working)
      ModelInfo(
        name: 'gemma-3-27b-it',
        displayName: 'Gemma 3 27B',
        category: ModelCategory.other,
        description: 'Open source, paling besar',
      ),
      ModelInfo(
        name: 'gemma-3-12b-it',
        displayName: 'Gemma 3 12B',
        category: ModelCategory.other,
        description: 'Open source, medium',
      ),
      ModelInfo(
        name: 'gemma-3-4b-it',
        displayName: 'Gemma 3 4B',
        category: ModelCategory.other,
        description: 'Open source, kecil',
      ),
      
      // ROBOTICS (Niche tapi working)
      ModelInfo(
        name: 'gemini-robotics-er-1.5-preview',
        displayName: 'Gemini Robotics ER 1.5',
        category: ModelCategory.other,
        description: 'Khusus robotics',
      ),
    ];
  }

  List<ModelInfo> getModelsByCategory(ModelCategory category) {
    return getAllModels().where((m) => m.category == category).toList();
  }

  String? getSavedModelName() {
    return prefs.getString('selectedModel');
  }

  Future<bool> saveModelName(String modelName) async {
    return await prefs.setString('selectedModel', modelName);
  }

  Future<void> init({String? modelName}) async {
    final apiKey = prefs.getString('geminiApiKey');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key belum di-set');
    }

    final selectedModel = modelName ?? 
                          getSavedModelName() ?? 
                          'gemini-2.5-flash'; // DEFAULT KE 2.5 YANG PALING STABIL!

    try {
      _model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024, // ✅ KURANGI TOKEN OUTPUT!
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
        // ✅ SYSTEM INSTRUCTION PENDEK - KAYAK PYTHON!
        systemInstruction: Content.text(
          'Kamu adalah "Robovan", asisten AI currency expert. '
          'Jawab pertanyaan tentang mata uang dalam Bahasa Indonesia dengan singkat dan jelas. '
          'Gunakan data yang diberikan dalam context.'
        ),
      );
      
      _chat = _model!.startChat();
      _currentModelName = selectedModel;
      
      await saveModelName(selectedModel);
      
      debugPrint('✅ Model initialized: $selectedModel');
    } catch (e) {
      debugPrint('❌ Failed to init model $selectedModel: ${e.toString()}');
      
      // Fallback ke model backup
      if (selectedModel != 'gemini-2.5-flash') {
        try {
          _model = GenerativeModel(
            model: 'gemini-2.5-flash', // Fallback ke 2.5 flash
            apiKey: apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.7,
              maxOutputTokens: 1024,
            ),
            systemInstruction: Content.text(
              'Kamu adalah "Robovan", asisten AI currency expert. '
              'Jawab dalam Bahasa Indonesia dengan singkat.'
            ),
          );
          _chat = _model!.startChat();
          _currentModelName = 'gemini-2.5-flash';
          await saveModelName('gemini-2.5-flash');
          debugPrint('✅ Fallback success: gemini-2.5-flash');
          return;
        } catch (e2) {
          debugPrint('❌ Fallback failed: ${e2.toString()}');
        }
      }
      
      throw Exception('Model tidak tersedia: ${e.toString()}');
    }
  }

  Future<String> getApiKey() async {
    return prefs.getString('geminiApiKey') ?? '';
  }

  Future<bool> setApiKey(String key) async {
    final success = await prefs.setString('geminiApiKey', key);
    if (success) {
      try {
        await init();
        return true;
      } catch (e) {
        debugPrint('Error saat init: ${e.toString()}');
        return false;
      }
    }
    return success;
  }

  // ✅ REAL FIX: Hapus semua logic rate limit yang salah!
  Future<String> sendMessage(String prompt) async {
    if (_chat == null) {
      throw Exception('Model belum diinisialisasi.');
    }
    
    try {
      // Build prompt dengan context
      final fullPrompt = _buildPromptWithContext(prompt);
      
      debugPrint('🤖 Sending message to Gemini...');
      
      // ✅ LANGSUNG KIRIM - seperti di Python kamu!
      final response = await _chat!.sendMessage(Content.text(fullPrompt));
      
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        return 'Maaf, tidak ada respons dari AI. Coba lagi.';
      }
      
      debugPrint('✅ Got response: ${responseText.length} chars');
      return responseText;
      
    } catch (e) {
      // ✅ REAL ERROR HANDLING - jangan asal sebut "quota"!
      debugPrint('❌ Error dari Gemini API: ${e.toString()}');
      
      // Tampilkan error asli ke user
      return '''
⚠️ Error dari Gemini API:

${e.toString()}

Kemungkinan penyebab:
1. Model tidak support chat (coba ganti model)
2. API key salah/expired
3. Koneksi internet bermasalah
4. Ada filter safety yang trigger

Coba:
- Ganti model ke "Gemini 1.5 Flash"
- Cek API key di aistudio.google.com
- Cek koneksi internet
''';
    }
  }

  // ✅ SIMPLIFIED - JANGAN KIRIM CONTEXT PANJANG!
  String _buildPromptWithContext(String userPrompt) {
    // Kalau pertanyaan simple (halo, thanks, dll), JANGAN kasih context!
    if (!_shouldIncludeContext(userPrompt)) {
      return userPrompt;
    }
    
    // Kalau butuh context, kasih yang RINGKAS aja
    final buffer = StringBuffer();
    buffer.writeln('DATA: ${_getSimplifiedContext()}');
    buffer.writeln();
    buffer.writeln('Q: $userPrompt');
    
    return buffer.toString();
  }

  bool _shouldIncludeContext(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('mata uang') ||
           lowerQuery.contains('currency') ||
           lowerQuery.contains('rate') ||
           lowerQuery.contains('kuat') ||
           lowerQuery.contains('lemah') ||
           lowerQuery.contains('prediksi') ||
           lowerQuery.contains('bandingkan');
  }

  String _getSimplifiedContext() {
    if (_currentRates == null || _currentBaseCurrency == null) {
      return 'No data';
    }
    
    var rankedRates = _currentRates!.entries.toList();
    rankedRates.sort((a, b) {
      final strengthA = 1 / (a.value as num);
      final strengthB = 1 / (b.value as num);
      return strengthB.compareTo(strengthA);
    });
    
    // ✅ SUPER RINGKAS - CUMA TOP 3 & BOTTOM 3!
    final buffer = StringBuffer();
    buffer.write('Base $_currentBaseCurrency | ');
    buffer.write('Strong: ');
    for (var i = 0; i < 3 && i < rankedRates.length; i++) {
      buffer.write('${rankedRates[i].key}(${(rankedRates[i].value as num).toStringAsFixed(2)}) ');
    }
    buffer.write('| Weak: ');
    final start = rankedRates.length - 3;
    for (var i = start < 0 ? 0 : start; i < rankedRates.length; i++) {
      buffer.write('${rankedRates[i].key}(${(rankedRates[i].value as num).toStringAsFixed(2)}) ');
    }
    
    return buffer.toString();
  }

  Future<bool> testModel(String modelName) async {
    final apiKey = prefs.getString('geminiApiKey');
    if (apiKey == null || apiKey.isEmpty) {
      return false;
    }

    try {
      final testModel = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );
      
      final chat = testModel.startChat();
      await chat.sendMessage(Content.text('test'));
      return true;
    } catch (e) {
      debugPrint('Test model $modelName failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> switchModel(String modelName) async {
    try {
      await init(modelName: modelName);
      return true;
    } catch (e) {
      debugPrint('Switch model failed: ${e.toString()}');
      return false;
    }
  }
}

// 5. Providers
final sharedPreferencesProvider =
    FutureProvider((ref) => SharedPreferences.getInstance());

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => GeminiService(prefs),
    loading: () => throw Exception('Loading preferences...'),
    error: (err, stack) => throw Exception('Error loading preferences: $err'),
  );
});