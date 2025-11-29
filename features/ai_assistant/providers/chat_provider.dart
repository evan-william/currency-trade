import 'package:flutter_riverpod/flutter_riverpod.dart';
// [FIXED] Menggunakan nama paket 'currency_changer'
import 'package:currency_changer/features/ai_assistant/services/gemini_service.dart';

// Provider untuk state list chat
final chatHistoryProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.watch(geminiServiceProvider));
});

// Provider untuk state loading AI
final aiLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk API Key
final apiKeyProvider = StateProvider<String?>((ref) => null);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;

  ChatNotifier(this._geminiService) : super([]);

  // Muat API key saat provider pertama kali dibuat
  Future<void> loadApiKey() async {
    state = [
      ChatMessage(
        'Halo! Saya Robovan. Ada yang bisa dibantu seputar mata uang?',
        isFromUser: false,
      )
    ];
    await _geminiService.init(); // Inisialisasi service
  }

  Future<void> sendMessage(String prompt, WidgetRef ref) async {
    // Tambahkan pesan user ke list
    state = [...state, ChatMessage(prompt)];
    ref.read(aiLoadingProvider.notifier).state = true;

    try {
      // Kirim ke Gemini dan dapatkan balasan
      final response = await _geminiService.sendMessage(prompt);
      state = [...state, ChatMessage(response, isFromUser: false)];
    } catch (e) {
      state = [...state, ChatMessage(e.toString(), isFromUser: false)];
    } finally {
      ref.read(aiLoadingProvider.notifier).state = false;
    }
  }
}