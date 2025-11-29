// FILE: lib/features/voice_assistant/screens/voice_assistant_screen.dart
// 🎤 FIXED: WEB SUPPORT with proper Indonesian TTS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:currency_changer/features/ai_assistant/services/gemini_service.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;

enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
}

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late AnimationController _waveController;

  VoiceState _currentState = VoiceState.idle;
  String _recognizedText = '';
  String _aiResponse = '';
  String _currentlySpeaking = '';
  double _confidence = 0.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceServices();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  Future<void> _initializeVoiceServices() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        if (mounted) {
          setState(() => _currentState = VoiceState.idle);
        }
      },
    );

    _flutterTts = FlutterTts();
    
    // ✅ KHUSUS WEB: Harus pakai cara ini
    if (kIsWeb) {
      await _flutterTts.setLanguage("id-ID");
      
      // Web pakai getVoices terus pilih Indonesian voice
      var voices = await _flutterTts.getVoices;
      debugPrint('Available voices: $voices');
      
      // Cari voice Indonesia
      var indonesianVoice = voices.firstWhere(
        (voice) => voice['name'].toString().contains('Indonesia') || 
                   voice['name'].toString().contains('id-ID') ||
                   voice['name'].toString().contains('id_ID'),
        orElse: () => voices.first,
      );
      
      debugPrint('Selected voice: $indonesianVoice');
      await _flutterTts.setVoice({"name": indonesianVoice['name'], "locale": indonesianVoice['locale']});
      
      await _flutterTts.setSpeechRate(0.8); // Web lebih cepat normalnya
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } else {
      // Mobile
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(0.95);
    }

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _currentState = VoiceState.speaking);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _currentState = VoiceState.idle;
          _currentlySpeaking = '';
        });
      }
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      if (mounted) {
        setState(() {
          _currentlySpeaking = text.substring(0, end);
        });
      }
    });

    if (mounted) {
      setState(() => _isInitialized = available);
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _currentState = VoiceState.listening;
      _recognizedText = '';
      _aiResponse = '';
      _confidence = 0.0;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _confidence = result.confidence;
          });
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      ),
      localeId: 'id_ID',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (_recognizedText.isNotEmpty) {
      _processVoiceInput();
    } else {
      if (mounted) {
        setState(() => _currentState = VoiceState.idle);
      }
    }
  }

  Future<void> _processVoiceInput() async {
    if (_recognizedText.isEmpty) {
      if (mounted) setState(() => _currentState = VoiceState.idle);
      return;
    }

    setState(() => _currentState = VoiceState.processing);

    try {
      final response = await ref
          .read(geminiServiceProvider)
          .sendMessage(_recognizedText);

      if (mounted) {
        setState(() => _aiResponse = response);
        await _speak(response);
      }
    } catch (e) {
      final errorMsg = 'Maaf, terjadi kesalahan: ${e.toString()}';
      if (mounted) {
        setState(() => _aiResponse = errorMsg);
        await _speak(errorMsg);
      }
    }
  }

  Future<void> _speak(String text) async {
    setState(() => _currentState = VoiceState.speaking);
    
    // ✅ STRIP MARKDOWN sebelum speak (hapus ** untuk bold, * untuk italic, dll)
    String cleanText = text
        .replaceAll('**', '')  // Bold
        .replaceAll('*', '')   // Italic
        .replaceAll('__', '')  // Underline
        .replaceAll('_', '')   // Italic alt
        .replaceAll('~~', '')  // Strikethrough
        .replaceAll('`', '')   // Code
        .replaceAll('#', '')   // Headers
        .trim();
    
    // ✅ Set language lagi sebelum speak (PENTING untuk Web!)
    if (kIsWeb) {
      await _flutterTts.setLanguage("id-ID");
    }
    
    await _flutterTts.speak(cleanText);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _currentState = VoiceState.idle;
        _currentlySpeaking = '';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Voice Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Animated Voice Wave Icon
                    _buildVoiceWaveIcon(),

                    const SizedBox(height: 40),

                    // Status Text
                    _buildStatusText(),

                    const SizedBox(height: 20),

                    // Recognized Text
                    if (_recognizedText.isNotEmpty)
                      _buildTextCard(
                        'You said:',
                        _recognizedText,
                        Colors.blue,
                        Icons.person,
                      ),

                    const SizedBox(height: 16),

                    // AI Response
                    if (_aiResponse.isNotEmpty)
                      _buildTextCard(
                        'Robovan:',
                        _currentState == VoiceState.speaking && _currentlySpeaking.isNotEmpty
                            ? _currentlySpeaking
                            : _aiResponse,
                        Colors.tealAccent,
                        Icons.smart_toy,
                      ),

                    const SizedBox(height: 20),

                    // Confidence
                    if (_confidence > 0 && _currentState == VoiceState.listening)
                      _buildConfidenceIndicator(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // Main Button
                  if (_currentState != VoiceState.speaking)
                    _buildMainButton(),

                  // Stop Speaking Button
                  if (_currentState == VoiceState.speaking)
                    ElevatedButton.icon(
                      onPressed: _stopSpeaking,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Speaking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),

                  // Done Speaking Button (when listening)
                  if (_currentState == VoiceState.listening)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: _stopListening,
                        icon: const Icon(Icons.check),
                        label: const Text('Done Speaking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceWaveIcon() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple Rings
            if (_currentState != VoiceState.idle) ...[
              _buildRipple(120, _waveController.value, 0.3),
              _buildRipple(160, _waveController.value + 0.2, 0.2),
              _buildRipple(200, _waveController.value + 0.4, 0.1),
            ],

            // Main Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _getGradientColors(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getIconColor().withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _getIconForState(),
                color: Colors.white,
                size: 50,
              ),
            ),

            // Voice Bars
            if (_currentState == VoiceState.listening)
              _buildVoiceBars(),
          ],
        );
      },
    );
  }

  Widget _buildRipple(double size, double value, double opacity) {
    return Container(
      width: size * (1 + value * 0.3),
      height: size * (1 + value * 0.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getIconColor().withValues(alpha: opacity * (1 - value)),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildVoiceBars() {
    return SizedBox(
      width: 200,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (index) {
          final phase = _waveController.value * 2 * math.pi;
          final height = 20 + 30 * math.sin(phase + index * 0.5).abs();
          
          return Container(
            width: 4,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.tealAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusText() {
    String statusText;
    Color statusColor;

    switch (_currentState) {
      case VoiceState.idle:
        statusText = 'Tap to speak';
        statusColor = Colors.grey;
        break;
      case VoiceState.listening:
        statusText = 'Listening...';
        statusColor = Colors.blue;
        break;
      case VoiceState.processing:
        statusText = 'Processing...';
        statusColor = Colors.orange;
        break;
      case VoiceState.speaking:
        statusText = 'Speaking...';
        statusColor = Colors.tealAccent;
        break;
    }

    return Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextCard(String label, String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMarkdownText(text, Colors.white),
        ],
      ),
    );
  }

  // ✅ Parse markdown dan render dengan TextSpan
  Widget _buildMarkdownText(String text, Color baseColor) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|__(.+?)__|_(.+?)_|~~(.+?)~~|`(.+?)`');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: baseColor, fontSize: 16, height: 1.5),
        ));
      }

      // Determine style based on match
      TextStyle style = TextStyle(color: baseColor, fontSize: 16, height: 1.5);
      String matchedText = '';

      if (match.group(1) != null) {
        // **bold**
        matchedText = match.group(1)!;
        style = style.copyWith(fontWeight: FontWeight.bold);
      } else if (match.group(2) != null) {
        // *italic*
        matchedText = match.group(2)!;
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (match.group(3) != null) {
        // __underline__
        matchedText = match.group(3)!;
        style = style.copyWith(decoration: TextDecoration.underline);
      } else if (match.group(4) != null) {
        // _italic alt_
        matchedText = match.group(4)!;
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (match.group(5) != null) {
        // ~~strikethrough~~
        matchedText = match.group(5)!;
        style = style.copyWith(decoration: TextDecoration.lineThrough);
      } else if (match.group(6) != null) {
        // `code`
        matchedText = match.group(6)!;
        style = style.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
        );
      }

      spans.add(TextSpan(text: matchedText, style: style));
      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: baseColor, fontSize: 16, height: 1.5),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildConfidenceIndicator() {
    return Column(
      children: [
        Text(
          'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _confidence,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(
            _confidence > 0.7 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _currentState == VoiceState.idle ? _startListening : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: _currentState == VoiceState.idle
                ? [Colors.tealAccent, Colors.teal]
                : [Colors.grey, Colors.grey[800]!],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.tealAccent.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _currentState == VoiceState.idle ? Icons.mic : Icons.hourglass_empty,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Color _getIconColor() {
    switch (_currentState) {
      case VoiceState.idle:
        return Colors.grey;
      case VoiceState.listening:
        return Colors.blue;
      case VoiceState.processing:
        return Colors.orange;
      case VoiceState.speaking:
        return Colors.tealAccent;
    }
  }

  List<Color> _getGradientColors() {
    switch (_currentState) {
      case VoiceState.idle:
        return [Colors.grey[700]!, Colors.grey[900]!];
      case VoiceState.listening:
        return [Colors.blue, Colors.blueAccent];
      case VoiceState.processing:
        return [Colors.orange, Colors.deepOrange];
      case VoiceState.speaking:
        return [Colors.tealAccent, Colors.teal];
    }
  }

  IconData _getIconForState() {
    switch (_currentState) {
      case VoiceState.idle:
        return Icons.mic_none;
      case VoiceState.listening:
        return Icons.mic;
      case VoiceState.processing:
        return Icons.psychology;
      case VoiceState.speaking:
        return Icons.volume_up;
    }
  }
}