import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/voice_service.dart';
import '../../models/reminder.dart';
import '../../repositories/reminder_repository.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/pulsing_orb.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _voice = VoiceService.instance;
  String _transcript = '';
  VoiceStatus _status = VoiceStatus.idle;
  bool _saving = false;
  Reminder? _saved;

  late StreamSubscription _t;
  late StreamSubscription _s;

  @override
  void initState() {
    super.initState();
    _voice.init();
    _t = _voice.transcript.listen((t) {
      if (mounted) setState(() => _transcript = t);
    });
    _s = _voice.status.listen((s) {
      if (mounted) setState(() => _status = s);
      // When speech recognition finishes on its own, save automatically.
      if (s == VoiceStatus.processing &&
          _transcript.trim().isNotEmpty &&
          !_saving) {
        _stopAndSave();
      }
    });
  }

  @override
  void dispose() {
    _t.cancel();
    _s.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    debugPrint('_startListening tapped');
    final ready = await _voice.ensureInitialized();
    final hasPerm = await _voice.hasPermission;
    debugPrint('stt ready=$ready, hasPermission=$hasPerm');
    if (!ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition unavailable on this device.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _transcript = '';
      _saved = null;
    });
    await _voice.startListening();
  }

  Future<void> _stopAndSave() async {
    await _voice.stopListening();
    if (_transcript.trim().isEmpty) return;

    setState(() => _saving = true);
    final repo = ref.read(reminderRepositoryProvider);
    final parsed = await repo.parseNaturalLanguage(_transcript);

    if (parsed == null) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't understand. Try again?")),
        );
      }
      return;
    }

    final reminder = Reminder(
      id: const Uuid().v4(),
      userId: '',
      title: parsed['title'] as String,
      notes: parsed['notes'] as String?,
      scheduledAt: DateTime.parse(parsed['scheduled_at'] as String),
      recurrence: _parseRecurrence(parsed['recurrence'] as String?),
      alertType: parsed['alert_type'] == 'call'
          ? AlertType.call
          : AlertType.alert,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final saved = await repo.create(reminder);
      await _voice.speak(_confirmationLine(saved));
      setState(() {
        _saved = saved;
        _saving = false;
      });
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Recurrence _parseRecurrence(String? raw) {
    switch (raw) {
      case 'daily':
        return Recurrence.daily;
      case 'weekdays':
        return Recurrence.weekdays;
      case 'weekly':
        return Recurrence.weekly;
      default:
        return Recurrence.none;
    }
  }

  String _confirmationLine(Reminder r) {
    return r.isCall
        ? "I'll call you at the scheduled time."
        : "I'll remind you when it's time.";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF1A1408), AnnaColors.bg],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AnnaColors.surface,
                      border: Border.all(color: AnnaColors.line),
                    ),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          _statusLabel(),
                          style: AnnaText.eyebrowGold.copyWith(letterSpacing: 3),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: PulsingOrb(
                            active: _status == VoiceStatus.listening),
                      ),
                      const SizedBox(height: 24),
                      _buildBody(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_saved != null) {
      return _ConfirmationCard(reminder: _saved!);
    }
    if (_transcript.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          '"$_transcript"',
          textAlign: TextAlign.center,
          style: AnnaText.italicCaption.copyWith(
            fontSize: 22,
            color: AnnaColors.text,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Tap the orb or hit the mic button',
            style: AnnaText.italicCaption,
          ),
        ),
        const SizedBox(height: 14),
        ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _Suggestion(text: s, onTap: _startListening),
            )),
      ],
    );
  }

  Widget _buildAction() {
    final listening = _status == VoiceStatus.listening;
    return ElevatedButton.icon(
      onPressed: _saving
          ? null
          : listening
              ? _stopAndSave
              : _startListening,
      icon: _saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AnnaColors.bg,
              ),
            )
          : Icon(listening ? Icons.stop : Icons.mic, color: AnnaColors.bg),
      label: Text(
        _saving
            ? 'Saving...'
            : listening
                ? 'Done'
                : 'Tap to talk',
        style: const TextStyle(
          fontFamily: 'InstrumentSerif',
          fontStyle: FontStyle.italic,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (_status) {
      case VoiceStatus.listening:
        return '● ANNA IS LISTENING';
      case VoiceStatus.processing:
        return '● PROCESSING...';
      case VoiceStatus.error:
        return '● ERROR — TRY AGAIN';
      case VoiceStatus.idle:
        return '● READY';
    }
  }
}

const _suggestions = [
  'Remind me in 30 minutes to stretch',
  'Call me at 3pm to check on the deploy',
  'Take meds every day at 9am — call me',
];

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AnnaColors.line),
          color: AnnaColors.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.bolt, size: 14, color: AnnaColors.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: AnnaText.bodySoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AnnaColors.gold),
        color: AnnaColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONFIRMED REMINDER', style: AnnaText.eyebrowGold),
          const SizedBox(height: 6),
          Text(reminder.title,
              style: AnnaText.sectionTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              _Chip(label: '${reminder.scheduledAt.toLocal()}'.split('.').first),
              _Chip(
                label: reminder.isCall ? '📞 CALL' : '🔔 ALERT',
                gold: reminder.isCall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.gold = false});
  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: gold
            ? AnnaColors.gold.withOpacity(0.1)
            : AnnaColors.surface2,
      ),
      child: Text(
        label.toUpperCase(),
        style: AnnaText.meta.copyWith(
          color: gold ? AnnaColors.gold : AnnaColors.textSoft,
        ),
      ),
    );
  }
}