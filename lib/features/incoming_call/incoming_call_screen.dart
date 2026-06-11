import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/notification_service.dart';
import '../../core/voice_service.dart';
import '../../models/reminder.dart';
import '../../repositories/reminder_repository.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key, required this.reminderId});
  final String reminderId;

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  Reminder? _reminder;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(reminderRepositoryProvider);
    final r = await repo.getById(widget.reminderId);
    if (mounted && r != null) {
      setState(() => _reminder = r);
    }
  }

  Future<void> _answer() async {
    await NotificationService.instance.stopRinging(widget.reminderId);
    setState(() => _connected = true);
    await VoiceService.instance.speak(
      "Hello. ${_reminder?.title ?? 'Time for your reminder'}. "
      "Have you taken care of it yet?",
    );
  }

  Future<void> _dismiss() async {
    await NotificationService.instance.stopRinging(widget.reminderId);
    if (mounted) context.go('/');
  }

  Future<void> _snooze() async {
    await NotificationService.instance.stopRinging(widget.reminderId);
    final repo = ref.read(reminderRepositoryProvider);
    final r = _reminder;
    if (r != null) {
      final snoozed = r.copyWith(
        scheduledAt: DateTime.now().add(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );
      await repo.update(snoozed);
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final r = _reminder;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFF2A1F0A), AnnaColors.bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _connected ? '● CONNECTED' : '● INCOMING REMINDER',
                  style: AnnaText.eyebrowGold.copyWith(letterSpacing: 3),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AnnaColors.gold, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: AnnaColors.goldGlow, blurRadius: 60),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/anna-logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Anna', style: AnnaText.callerName),
                const SizedBox(height: 6),
                if (r != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '"${r.title}"',
                      style: AnnaText.italicCaption.copyWith(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                Text('REMINDER · NOW',
                    style: AnnaText.meta.copyWith(letterSpacing: 2.5)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CallButton(
                      label: 'DISMISS',
                      icon: Icons.call_end,
                      color: AnnaColors.red,
                      onTap: _dismiss,
                    ),
                    _CallButton(
                      label: 'SNOOZE',
                      icon: Icons.snooze,
                      color: AnnaColors.surface2,
                      borderColor: AnnaColors.line,
                      onTap: _snooze,
                    ),
                    _CallButton(
                      label: _connected ? 'END' : 'ANSWER',
                      icon: _connected ? Icons.call_end : Icons.call,
                      color: _connected ? AnnaColors.red : AnnaColors.green,
                      onTap: _connected ? _dismiss : _answer,
                      pulse: !_connected,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatefulWidget {
  const _CallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.borderColor,
    this.pulse = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final VoidCallback onTap;
  final bool pulse;

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final offset = widget.pulse ? -3.0 * _c.value : 0.0;
              return Transform.translate(offset: Offset(0, offset), child: child);
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!)
                    : null,
                boxShadow: widget.color == AnnaColors.surface2
                    ? null
                    : [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 30)],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(height: 10),
          Text(widget.label, style: AnnaText.meta),
        ],
      ),
    );
  }
}