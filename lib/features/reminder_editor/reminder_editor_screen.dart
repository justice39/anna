import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/reminder.dart';
import '../../repositories/reminder_repository.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ReminderEditorScreen extends ConsumerStatefulWidget {
  const ReminderEditorScreen({super.key, this.reminderId});
  final String? reminderId;

  @override
  ConsumerState<ReminderEditorScreen> createState() =>
      _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends ConsumerState<ReminderEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _scheduledAt =
      DateTime.now().add(const Duration(hours: 1)).copyWith(second: 0);
  Recurrence _recurrence = Recurrence.none;
  AlertType _alert = AlertType.alert;
  bool _isCritical = false;
  String _ringtone = 'bell_chime';

  bool _loading = false;
  bool get _isEdit => widget.reminderId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final r = await ref
        .read(reminderRepositoryProvider)
        .getById(widget.reminderId!);
    if (r != null) {
      setState(() {
        _titleCtrl.text = r.title;
        _notesCtrl.text = r.notes ?? '';
        _scheduledAt = r.scheduledAt;
        _recurrence = r.recurrence;
        _alert = r.alertType;
        _isCritical = r.isCritical;
        _ringtone = r.ringtone;
      });
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AnnaColors.gold,
            onPrimary: AnnaColors.bg,
            surface: AnnaColors.surface,
            onSurface: AnnaColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AnnaColors.gold,
            onPrimary: AnnaColors.bg,
            surface: AnnaColors.surface,
            onSurface: AnnaColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your reminder a title')),
      );
      return;
    }
    setState(() => _loading = true);
    final repo = ref.read(reminderRepositoryProvider);
    final now = DateTime.now();

    final reminder = Reminder(
      id: widget.reminderId ?? const Uuid().v4(),
      userId: '',
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      scheduledAt: _scheduledAt,
      recurrence: _recurrence,
      alertType: _alert,
      isCritical: _isCritical,
      ringtone: _ringtone,
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (_isEdit) {
        await repo.update(reminder);
      } else {
        await repo.create(reminder);
      }
      ref.invalidate(remindersStreamProvider);
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AnnaColors.surface,
        title: const Text('Delete reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AnnaColors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(reminderRepositoryProvider).delete(widget.reminderId!);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AnnaColors.gold))
            : Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        InkWell(
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
                        const Spacer(),
                        if (_isEdit)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AnnaColors.red),
                            onPressed: _delete,
                          ),
                        TextButton(
                          onPressed: _save,
                          child: Text(
                            'Save',
                            style: AnnaText.italicCaption.copyWith(
                              color: AnnaColors.gold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: AnnaText.greeting.copyWith(fontSize: 28),
                        children: [
                          TextSpan(
                              text: _isEdit ? 'Edit ' : 'New ',
                              style: AnnaText.greetingAccent
                                  .copyWith(fontSize: 28)),
                          const TextSpan(text: 'reminder'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          _Field(
                            label: 'WHAT SHOULD I REMIND YOU?',
                            child: TextField(
                              controller: _titleCtrl,
                              decoration:
                                  const InputDecoration(hintText: 'Title'),
                              style: AnnaText.body,
                            ),
                          ),
                          _Field(
                            label: 'WHEN',
                            child: InkWell(
                              onTap: _pickDateTime,
                              borderRadius: BorderRadius.circular(11),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  border:
                                      Border.all(color: AnnaColors.line),
                                  color: AnnaColors.surface,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEEE, d MMM · h:mm a')
                                            .format(_scheduledAt),
                                        style: AnnaText.body,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward,
                                        size: 16, color: AnnaColors.gold),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _Field(
                            label: 'REPEAT',
                            child: _RecurrencePicker(
                              current: _recurrence,
                              onChange: (r) =>
                                  setState(() => _recurrence = r),
                            ),
                          ),
                          _Field(
                            label: 'HOW SHOULD ANNA REMIND YOU?',
                            child: Row(
                              children: [
                                Expanded(
                                  child: _AlertPill(
                                    label: '🔔 ALERT',
                                    active: _alert == AlertType.alert,
                                    onTap: () => setState(
                                        () => _alert = AlertType.alert),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _AlertPill(
                                    label: '📞 CALL',
                                    active: _alert == AlertType.call,
                                    onTap: () => setState(
                                        () => _alert = AlertType.call),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_alert == AlertType.call)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color:
                                        AnnaColors.gold.withOpacity(0.3)),
                                color: AnnaColors.gold.withOpacity(0.08),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: AnnaColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Critical reminder',
                                            style: AnnaText.body.copyWith(
                                                color: AnnaColors.gold,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                            'Will ring through silent mode',
                                            style: AnnaText.meta),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isCritical,
                                    activeColor: AnnaColors.gold,
                                    onChanged: (v) =>
                                        setState(() => _isCritical = v),
                                  ),
                                ],
                              ),
                            ),
                          _Field(
                            label: 'NOTES (OPTIONAL)',
                            child: TextField(
                              controller: _notesCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Anything else?',
                              ),
                              style: AnnaText.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AnnaText.eyebrow),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _RecurrencePicker extends StatelessWidget {
  const _RecurrencePicker({required this.current, required this.onChange});
  final Recurrence current;
  final ValueChanged<Recurrence> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: Recurrence.values.map((r) {
        final active = r == current;
        return InkWell(
          onTap: () => onChange(r),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? AnnaColors.gold : AnnaColors.line,
              ),
              color: active ? AnnaColors.gold.withOpacity(0.1) : null,
            ),
            child: Text(
              _label(r),
              style: AnnaText.meta.copyWith(
                color: active ? AnnaColors.gold : AnnaColors.textSoft,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(Recurrence r) {
    switch (r) {
      case Recurrence.none:
        return 'ONCE';
      case Recurrence.daily:
        return 'DAILY';
      case Recurrence.weekdays:
        return 'WEEKDAYS';
      case Recurrence.weekly:
        return 'WEEKLY';
    }
  }
}

class _AlertPill extends StatelessWidget {
  const _AlertPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AnnaColors.gold : AnnaColors.line),
          color: active ? AnnaColors.gold : AnnaColors.surface,
          boxShadow: active
              ? [BoxShadow(color: AnnaColors.goldGlow, blurRadius: 16)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AnnaText.meta.copyWith(
              color: active ? AnnaColors.bg : AnnaColors.textSoft,
            ),
          ),
        ),
      ),
    );
  }
}
