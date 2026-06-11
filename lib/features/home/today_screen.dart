import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/reminder_repository.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/pulsing_orb.dart';
import '../../widgets/reminder_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = (user?.userMetadata?['full_name'] as String?)
            ?.split(' ')
            .first ??
        user?.email?.split('@').first ??
        'there';

    return SafeArea(
      child: remindersAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AnnaColors.gold)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Couldn’t load your reminders.\n$e',
              style: AnnaText.bodySoft,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (all) {
          final now = DateTime.now();
          final endOfToday = DateTime(now.year, now.month, now.day, 23, 59);
          final today = all
              .where((r) =>
                  r.isActive &&
                  r.scheduledAt.isAfter(now.subtract(const Duration(minutes: 1))) &&
                  r.scheduledAt.isBefore(endOfToday))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
            children: [
              _Header(name: displayName),
              const SizedBox(height: 24),
              _VoiceCTA(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('COMING UP', style: AnnaText.eyebrow),
                  const Spacer(),
                  Text('${today.length} TODAY',
                      style: AnnaText.eyebrowGold),
                ],
              ),
              const SizedBox(height: 12),
              if (today.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No more reminders today.\nTap mic to add one.',
                      style: AnnaText.italicCaption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...today.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ReminderCard(
                        reminder: r,
                        onTap: () => context.go('/reminder/${r.id}'),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: AnnaText.eyebrow),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: AnnaText.greeting,
                  children: [
                    const TextSpan(text: 'Hello, '),
                    TextSpan(text: name, style: AnnaText.greetingAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AnnaColors.surface,
            border: Border.all(color: AnnaColors.line),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline,
              size: 18, color: AnnaColors.text),
        ),
      ],
    );
  }
}

class _VoiceCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final state =
            context.findAncestorStateOfType<State>(); // simple approach
        // The parent HomeShell handles tab switch via its tabbar; for now
        // we just navigate using GoRouter to a dedicated route if needed.
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AnnaColors.line),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1812), AnnaColors.surface],
          ),
        ),
        child: Row(
          children: [
            const PulsingDot(size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 19,
                        color: AnnaColors.text,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(text: 'Tap to tell '),
                        TextSpan(
                          text: 'Anna',
                          style: GoogleFonts.instrumentSerif(
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            color: AnnaColors.gold,
                          ),
                        ),
                        const TextSpan(text: ' a reminder'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('SPEAK NATURALLY · I’LL HANDLE THE REST',
                      style: AnnaText.meta),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AnnaColors.textSoft),
          ],
        ),
      ),
    );
  }
}
