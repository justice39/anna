import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reminder.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onComplete,
  });

  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final imminent = reminder.isImminent;
    final time = DateFormat('h:mm').format(reminder.scheduledAt);
    final period = imminent
        ? _imminentLabel(reminder.timeUntil)
        : DateFormat('a').format(reminder.scheduledAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: imminent ? AnnaColors.gold : AnnaColors.line,
            ),
            gradient: imminent
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1812), AnnaColors.surface],
                  )
                : null,
            color: imminent ? null : AnnaColors.surface,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imminent)
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AnnaColors.gold,
                    boxShadow: [
                      BoxShadow(color: AnnaColors.goldGlow, blurRadius: 8),
                    ],
                  ),
                ),
              if (imminent) const SizedBox(width: 10),
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    Text(
                      time,
                      style: AnnaText.timeNum.copyWith(
                        color: imminent ? AnnaColors.gold : AnnaColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(period.toUpperCase(), style: AnnaText.meta),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AnnaColors.line,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.title, style: AnnaText.reminderTitle),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (reminder.isCall) ...[
                          Text('📞 CALL',
                              style: AnnaText.meta
                                  .copyWith(color: AnnaColors.gold)),
                        ] else
                          Text('🔔 ALERT', style: AnnaText.meta),
                        Text(' · ', style: AnnaText.meta),
                        Text(reminder.recurrenceLabel.toUpperCase(),
                            style: AnnaText.meta),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: imminent ? AnnaColors.gold : AnnaColors.surface2,
                    border: Border.all(
                      color: imminent ? AnnaColors.gold : AnnaColors.line,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: imminent ? AnnaColors.bg : AnnaColors.textSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _imminentLabel(Duration d) {
    if (d.inMinutes < 1) return 'NOW';
    if (d.inMinutes < 60) return 'in ${d.inMinutes} min';
    return 'in ${d.inHours}h';
  }
}
