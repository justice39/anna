import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _callsAsRealCall = true;
  bool _persistentRing = true;
  bool _doNotDisturb = true;
  bool _allowCritical = true;

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
        children: [
          const SizedBox(height: 10),
          Text('PREFERENCES', style: AnnaText.eyebrow),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'Settings', style: AnnaText.greetingAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Group(
            label: 'CALLS',
            children: [
              _Row(
                title: 'Ring like a real call',
                sub: 'Full-screen even when silent',
                trailing: _Toggle(
                  value: _callsAsRealCall,
                  onChange: (v) => setState(() => _callsAsRealCall = v),
                ),
              ),
              _Row(
                title: 'Persistent ring',
                sub: 'Until you answer',
                trailing: _Toggle(
                  value: _persistentRing,
                  onChange: (v) => setState(() => _persistentRing = v),
                ),
              ),
              const _Row(
                title: 'Ringtone',
                sub: 'Bell chime',
                trailing: _Arrow(),
              ),
            ],
          ),
          _Group(
            label: 'VOICE',
            children: [
              const _Row(
                title: 'Voice tone',
                sub: 'Warm · British accent',
                trailing: _Arrow(),
              ),
              const _Row(
                title: 'Siri Shortcut',
                sub: '"Hey Siri, Anna"',
                trailing: _Arrow(),
              ),
            ],
          ),
          _Group(
            label: 'QUIET HOURS',
            children: [
              _Row(
                title: 'Do not disturb',
                sub: '10:00 PM — 7:00 AM',
                trailing: _Toggle(
                  value: _doNotDisturb,
                  onChange: (v) => setState(() => _doNotDisturb = v),
                ),
              ),
              _Row(
                title: 'Allow critical alerts',
                sub: 'Medication & emergencies',
                trailing: _Toggle(
                  value: _allowCritical,
                  onChange: (v) => setState(() => _allowCritical = v),
                ),
              ),
            ],
          ),
          _Group(
            label: 'ACCOUNT',
            children: [
              InkWell(
                onTap: _signOut,
                child: _Row(
                  title: 'Sign out',
                  sub: Supabase.instance.client.auth.currentUser?.email ??
                      'Signed in',
                  trailing: const Icon(Icons.logout,
                      color: AnnaColors.red, size: 18),
                ),
              ),
            ],
          ),
          _Group(
            label: 'ABOUT',
            children: const [
              _Row(
                title: 'Anna',
                sub: 'Version 1.0.0 · Made with care',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AnnaText.eyebrow),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AnnaColors.line),
              color: AnnaColors.surface,
            ),
            child: Column(children: _withDividers(children)),
          ),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> kids) {
    final out = <Widget>[];
    for (var i = 0; i < kids.length; i++) {
      out.add(kids[i]);
      if (i != kids.length - 1) {
        out.add(const Divider(height: 1, color: AnnaColors.line));
      }
    }
    return out;
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.sub, this.trailing});
  final String title;
  final String sub;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AnnaText.body.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(sub.toUpperCase(), style: AnnaText.meta),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) => const Icon(Icons.arrow_forward_ios,
      size: 12, color: AnnaColors.textFaint);
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChange});
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeColor: AnnaColors.gold,
      activeTrackColor: AnnaColors.gold.withOpacity(0.4),
      inactiveTrackColor: AnnaColors.surface3,
      onChanged: onChange,
    );
  }
}
