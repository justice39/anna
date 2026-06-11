import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Tap-to-talk voice service. v1 only — no wake word.
class VoiceService {
  VoiceService._();
  static final instance = VoiceService._();

  final _stt = stt.SpeechToText();
  final _tts = FlutterTts();

  bool _sttReady = false;

  final _transcriptController = StreamController<String>.broadcast();
  final _statusController = StreamController<VoiceStatus>.broadcast();

  Stream<String> get transcript => _transcriptController.stream;
  Stream<VoiceStatus> get status => _statusController.stream;

  Future<bool> init() async {
    _sttReady = await _stt.initialize(
      onStatus: (s) {
        if (s == 'listening') _statusController.add(VoiceStatus.listening);
        if (s == 'notListening') _statusController.add(VoiceStatus.idle);
        if (s == 'done') _statusController.add(VoiceStatus.processing);
      },
      onError: (e) {
        debugPrint('STT error: $e');
        _statusController.add(VoiceStatus.error);
      },
    );

    // Configure TTS to feel like Anna
    await _tts.setLanguage('en-GB');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);

    return _sttReady;
  }

  Future<void> startListening() async {
    if (!_sttReady) await init();
    if (_stt.isListening) return;

    await _stt.listen(
      onResult: (result) {
        _transcriptController.add(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );

    _statusController.add(VoiceStatus.listening);
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _statusController.add(VoiceStatus.idle);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  bool get isListening => _stt.isListening;

  void dispose() {
    _transcriptController.close();
    _statusController.close();
  }
}

enum VoiceStatus { idle, listening, processing, error }
