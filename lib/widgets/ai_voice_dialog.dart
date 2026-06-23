import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:amar_hisab/services/ai_service.dart';

import '../theme/app_colors.dart';

class AiVoiceDialog extends StatefulWidget {
  final String apiKey;

  const AiVoiceDialog({Key? key, required this.apiKey}) : super(key: key);

  @override
  State<AiVoiceDialog> createState() => _AiVoiceDialogState();
}

class _AiVoiceDialogState extends State<AiVoiceDialog> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'বলতে শুরু করুন...';
  double _confidence = 1.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
          if (_text.isNotEmpty && _text != 'বলতে শুরু করুন...' && _text != 'কথা শোনা যাচ্ছে না, আবার চেষ্টা করুন') {
            _processVoiceCommand();
          }
        }
      },
      onError: (val) {
        setState(() {
          _isListening = false;
          _text = 'কথা শোনা যাচ্ছে না, আবার চেষ্টা করুন';
        });
      },
    );
    if (available) {
      _listen();
    } else {
      setState(() {
        _text = 'আপনার ডিভাইসে ভয়েস রেকর্ডিং সমর্থিত নয়।';
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _processVoiceCommand() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AiService.parseVoiceCommand(_text, widget.apiKey);
    
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'এআই ভয়েস কমান্ড',
              style: GoogleFonts.hindSiliguri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('AI বিশ্লেষণ করছে...'),
                ],
              )
            else ...[
              GestureDetector(
                onTap: _listen,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isListening ? Colors.red : AppColors.primary,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _text,
                  style: GoogleFonts.hindSiliguri(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!_isListening && _text.isNotEmpty && _text != 'বলতে শুরু করুন...' && _text != 'কথা শোনা যাচ্ছে না, আবার চেষ্টা করুন')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: _processVoiceCommand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text('নিশ্চিত করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
