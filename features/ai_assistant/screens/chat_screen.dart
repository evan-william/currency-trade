// FILE: lib/features/ai_assistant/screens/chat_screen.dart
// ✅ FIXED: Voice button + Markdown support (bold, italic, etc)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_changer/features/ai_assistant/providers/chat_provider.dart';
import 'package:currency_changer/features/ai_assistant/services/gemini_service.dart';
import 'package:currency_changer/features/voice_assistant/screens/voice_assistant_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInitialized = false;
  String? _apiKey;
  String? _currentModel;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final prefsAsync = ref.read(sharedPreferencesProvider);
      
      prefsAsync.when(
        data: (prefs) async {
          final key = await ref.read(geminiServiceProvider).getApiKey();
          final model = ref.read(geminiServiceProvider).getSavedModelName();
          
          if (mounted) {
            setState(() {
              _apiKey = key;
              _currentModel = model ?? 'gemini-2.5-flash';
              _isInitialized = true;
            });

            if (key.isNotEmpty) {
              await ref.read(chatHistoryProvider.notifier).loadApiKey();
            }
          }
        },
        loading: () {},
        error: (err, stack) {
          if (mounted) {
            setState(() {
              _apiKey = '';
              _isInitialized = true;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiKey = '';
          _isInitialized = true;
        });
      }
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      ref
          .read(chatHistoryProvider.notifier)
          .sendMessage(_textController.text.trim(), ref);
      _textController.clear();
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showModelSelector() {
    final service = ref.read(geminiServiceProvider);
    final categories = [
      ModelCategory.chat,
      ModelCategory.experimental,
      ModelCategory.image,
      ModelCategory.video,
      ModelCategory.audio,
      ModelCategory.embedding,
      ModelCategory.other,
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Model Gemini'),
          content: SizedBox(
            width: double.maxFinite,
            child: DefaultTabController(
              length: categories.length,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: categories.map((cat) {
                      return Tab(text: _getCategoryName(cat));
                    }).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: categories.map((category) {
                        final models = service.getModelsByCategory(category);
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: models.length,
                          itemBuilder: (context, index) {
                            final model = models[index];
                            final isCurrent = model.name == _currentModel;
                            
                            return ListTile(
                              leading: Icon(
                                _getCategoryIcon(category),
                                color: isCurrent ? Colors.tealAccent : null,
                              ),
                              title: Text(
                                model.displayName,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : null,
                                  color: isCurrent ? Colors.tealAccent : null,
                                ),
                              ),
                              subtitle: Text(
                                model.description,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: isCurrent
                                  ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                                  : null,
                              onTap: () async {
                                Navigator.pop(dialogContext);
                                
                                if (!mounted) return;
                                
                                if (category != ModelCategory.chat && 
                                    category != ModelCategory.experimental) {
                                  if (!mounted) return;
                                  final proceed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('⚠️ Peringatan'),
                                      content: Text(
                                        'Model "${model.displayName}" adalah model khusus untuk ${_getCategoryName(category).toLowerCase()}.\n\n'
                                        'Model ini mungkin tidak mendukung chat biasa. Lanjutkan?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Lanjut'),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (proceed != true || !mounted) return;
                                }
                                
                                if (!mounted) return;
                                
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Switching ke ${model.displayName}...')),
                                );
                                
                                final success = await service.switchModel(model.name);
                                
                                if (!mounted) return;
                                
                                if (success) {
                                  setState(() {
                                    _currentModel = model.name;
                                  });
                                  
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('✅ Berhasil switch ke ${model.displayName}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Gagal switch ke ${model.displayName}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryName(ModelCategory category) {
    switch (category) {
      case ModelCategory.chat:
        return 'Chat';
      case ModelCategory.experimental:
        return 'Experimental';
      case ModelCategory.image:
        return 'Gambar';
      case ModelCategory.video:
        return 'Video';
      case ModelCategory.audio:
        return 'Audio';
      case ModelCategory.embedding:
        return 'Embedding';
      case ModelCategory.other:
        return 'Lainnya';
    }
  }

  IconData _getCategoryIcon(ModelCategory category) {
    switch (category) {
      case ModelCategory.chat:
        return Icons.chat_bubble;
      case ModelCategory.experimental:
        return Icons.science;
      case ModelCategory.image:
        return Icons.image;
      case ModelCategory.video:
        return Icons.video_library;
      case ModelCategory.audio:
        return Icons.audiotrack;
      case ModelCategory.embedding:
        return Icons.data_array;
      case ModelCategory.other:
        return Icons.more_horiz;
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController(text: _apiKey);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Masukkan Gemini API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dapatkan API key gratis di:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'https://aistudio.google.com/app/apikey',
                style: TextStyle(fontSize: 12, color: Colors.tealAccent),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  hintText: 'Paste API Key di sini...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  
                  if (!mounted) return;
                  
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Menginisialisasi model...')),
                  );
                  
                  final success = await ref.read(geminiServiceProvider).setApiKey(key);
                  
                  if (!mounted) return;
                  
                  if (success) {
                    await ref.read(chatHistoryProvider.notifier).loadApiKey();
                    setState(() {
                      _apiKey = key;
                    });
                    
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ API Key berhasil disimpan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal menginisialisasi. Cek API Key Anda.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatHistory = ref.watch(chatHistoryProvider);
    final isLoading = ref.watch(aiLoadingProvider);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat...'),
            ],
          ),
        ),
      );
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Setup Asisten')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.vpn_key_rounded,
                  size: 80,
                  color: Colors.tealAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fitur AI "Robovan" memerlukan Gemini API Key untuk berfungsi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'API key gratis bisa didapat di:\naistudio.google.com/app/apikey',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showApiKeyDialog,
                  icon: const Icon(Icons.vpn_key_rounded),
                  label: const Text('Masukkan API Key'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Robovan AI Assistant'),
            if (_currentModel != null)
              Text(
                'Model: ${_currentModel!.split('/').last}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.mic, size: 28),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                      .fadeOut(duration: 1000.ms)
                      .then()
                      .fadeIn(duration: 1000.ms),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceAssistantScreen(),
                ),
              );
            },
            tooltip: 'Voice Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: _showModelSelector,
            tooltip: 'Pilih Model',
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key_rounded),
            onPressed: _showApiKeyDialog,
            tooltip: 'Ganti API Key',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentModel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.tealAccent.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.model_training, size: 16, color: Colors.tealAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menggunakan: ${_currentModel!.split('/').last}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _showModelSelector,
                    child: const Text('Ganti', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai percakapan dengan Robovan!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Model: ${_currentModel?.split('/').last ?? 'gemini-2.5-flash'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = chatHistory[index];
                      return ChatBubble(message: message)
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 400));
                    },
                  ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Robovan sedang berpikir...'),
                ],
              ),
            ),
          _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Tanya Robovan sesuatu...',
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 16),
          IconButton.filled(
            icon: const Icon(Icons.send_rounded),
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ NEW: ChatBubble dengan Markdown support
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isFromUser
              ? theme.colorScheme.primary
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _buildMarkdownText(
          message.text,
          message.isFromUser ? Colors.black : Colors.white,
        ),
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
          style: TextStyle(color: baseColor),
        ));
      }

      // Determine style based on match
      TextStyle style = TextStyle(color: baseColor);
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
        style: TextStyle(color: baseColor),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}