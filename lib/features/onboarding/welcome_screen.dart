import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Logo mark
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AnnaColors.line),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1812), AnnaColors.bg],
                    ),
                    boxShadow: [
                      BoxShadow(color: AnnaColors.goldGlow, blurRadius: 60),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo/anna-logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AnnaText.callerName.copyWith(fontSize: 38),
                    children: [
                      const TextSpan(text: "Hello, I'm "),
                      TextSpan(text: 'Anna', style: AnnaText.greetingAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Your gentle reminder companion.\nI’ll call you when it’s time.',
                  style: AnnaText.italicCaption,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text(
                  'Get started',
                  style: TextStyle(
                    fontFamily: 'InstrumentSerif',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: Text(
                  'I HAVE AN ACCOUNT  →',
                  style: AnnaText.meta.copyWith(color: AnnaColors.textSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
