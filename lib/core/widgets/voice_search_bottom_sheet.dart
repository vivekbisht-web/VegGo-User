import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/permission_handler_service.dart';

class VoiceSearchBottomSheet extends StatefulWidget {
  final ValueChanged<String> onResult;

  const VoiceSearchBottomSheet({super.key, required this.onResult});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onResult,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => VoiceSearchBottomSheet(onResult: onResult),
    );
  }

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startListening();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      final hasPermission =
          await PermissionHandlerService.handleMicrophonePermission(
            showFeedback: true,
          );
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusMessage = AppStrings.microphonePermissionDenied;
          });
        }
        return;
      }

      bool available = await _speech.initialize(
        onError: (val) {
          debugPrint('Voice error: $val');
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = val.errorMsg;
            });
          }
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
            if (_recognizedText.trim().isNotEmpty) {
              widget.onResult(_recognizedText.trim());
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          }
        },
      );

      if (available) {
        if (mounted) {
          setState(() {
            _isListening = true;
            _statusMessage = '';
          });
        }
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _recognizedText = val.recognizedWords;
              });
            }
            if (val.finalResult && val.recognizedWords.trim().isNotEmpty) {
              widget.onResult(val.recognizedWords.trim());
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusMessage = AppStrings.speechNotAvailable;
          });
        }
      }
    } catch (e) {
      debugPrint('Error starting voice recognition: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusMessage = AppStrings.speechNotAvailable;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll24,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.radius40,
            height: AppSpacing.radius4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSpacing.radius2),
            ),
          ),
          AppSpacing.h20,

          Text(
            _isListening ? AppStrings.listeningForItems : AppStrings.voiceSearch,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          AppSpacing.h8,

          Text(
            _recognizedText.isNotEmpty
                ? _recognizedText
                : (_statusMessage.isNotEmpty
                    ? _statusMessage
                    : AppStrings.voiceSearchHint),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _recognizedText.isNotEmpty
                      ? AppColors.primary
                      : (_statusMessage.isNotEmpty
                          ? AppColors.error
                          : AppColors.textSecondary),
                  fontWeight: _recognizedText.isNotEmpty
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
          ),
          AppSpacing.h32,

          // Pulsing microphone icon
          ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.15).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (_isListening) {
                  _speech.stop();
                  setState(() => _isListening = false);
                } else {
                  _startListening();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening ? AppColors.surface : AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ),
          AppSpacing.h24,

          Text(
            _isListening
                ? AppStrings.tapMicToPause
                : AppStrings.tapMicToStart,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}
