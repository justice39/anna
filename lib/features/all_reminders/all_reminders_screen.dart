import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../repositories/reminder_repository.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/reminder_card.dart';

class AllRemindersScreen extends ConsumerWidget {
  const AllRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);

    return SafeArea(
      child: remindersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AnnaColors.gold),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final active = all.where((r) => r.isActive).toList();
          final snoozed = all.where((r) => !r.isActive).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
            children: [
              const SizedBox(height: 10),
              Text('LIBRARY', style: AnnaText.eyebrow),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: AnnaText.greeting,
                  children: [
                    TextSpan(text: 'All ', style: AnnaText.greetingAccent),
                    const TextSpan(text: 'reminders'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('ACTIVE', style: AnnaText.eyebrow),
                  const Spacer(),
                  Text('${active.length}', style: AnnaText.eyebrowGold),
                ],
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'No active reminders yet.\nTap + to create one.',
                      style: AnnaText.italicCaption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...active.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ReminderCard(
                        reminder: r,
                        onTap: () => context.go('/reminder/${r.id}'),
                      ),
                    )),
              if (snoozed.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('SNOOZED', style: AnnaText.eyebrow),
                    const Spacer(),
                    Text('${snoozed.length}', style: AnnaText.eyebrowGold),
                  ],
                ),
                const SizedBox(height: 12),
                ...snoozed.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Opacity(
                        opacity: 0.6,
                        child: ReminderCard(
                          reminder: r,
                          onTap: () => context.go('/reminder/${r.id}'),
                        ),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
