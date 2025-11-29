// FILE: lib/features/voice_assistant/widgets/voice_assistant_fab.dart
// 🎤 Floating Action Button untuk Voice Assistant (Siri-like pulse effect)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:currency_changer/features/voice_assistant/screens/voice_assistant_screen.dart';

class VoiceAssistantFAB extends StatelessWidget {
  const VoiceAssistantFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Pulse Ring
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.tealAccent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ).animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.4, 1.4),
              duration: 2000.ms,
            )
            .fadeOut(duration: 2000.ms),

        // Main Button
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VoiceAssistantScreen(),
              ),
            );
          },
          backgroundColor: Colors.tealAccent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Microphone Icon
              const Icon(
                Icons.mic,
                color: Colors.black,
                size: 28,
              ),
              
              // Voice Wave Indicator
              Positioned(
                bottom: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 3,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .scaleY(
                          begin: 0.5,
                          end: 1.0,
                          duration: 600.ms,
                          delay: (index * 100).ms,
                        )
                        .then()
                        .scaleY(begin: 1.0, end: 0.5, duration: 600.ms);
                  }),
                ),
              ),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 3000.ms,
              color: Colors.white.withValues(alpha: 0.3),
            ),
      ],
    );
  }
}