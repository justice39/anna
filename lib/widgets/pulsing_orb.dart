import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// The big breathing gold orb used on the voice screen and CTAs.
class PulsingOrb extends StatefulWidget {
  const PulsingOrb({
    super.key,
    this.size = 200,
    this.active = true,
  });

  final double size;
  final bool active;

  @override
  State<PulsingOrb> createState() => _PulsingOrbState();
}

class _PulsingOrbState extends State<PulsingOrb>
    with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final List<AnimationController> _rings = List.generate(3, (i) {
    final c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    Future.delayed(Duration(seconds: i), () {
      if (mounted) c.repeat();
    });
    return c;
  });

  @override
  void dispose() {
    _breathe.dispose();
    for (final c in _rings) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Three pulsing rings
          for (final ring in _rings)
            AnimatedBuilder(
              animation: ring,
              builder: (context, _) {
                return Container(
                  width: widget.size * (0.6 + 0.4 * ring.value),
                  height: widget.size * (0.6 + 0.4 * ring.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          AnnaColors.gold.withOpacity(0.5 * (1 - ring.value)),
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          // Core orb
          AnimatedBuilder(
            animation: _breathe,
            builder: (context, _) {
              final scale = widget.active ? 1.0 + 0.15 * _breathe.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.4,
                  height: widget.size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AnnaColors.goldSoft,
                        AnnaColors.gold,
                        AnnaColors.goldDeep,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AnnaColors.goldGlow,
                        blurRadius: 60,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Smaller pulse for inline use (like the home screen voice CTA).
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, this.size = 48});
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              return Transform.scale(
                scale: 1 + _c.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AnnaColors.gold.withOpacity(1 - _c.value),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AnnaColors.gold,
              boxShadow: [
                BoxShadow(color: AnnaColors.goldGlow, blurRadius: 30),
              ],
            ),
            child: Icon(Icons.mic, color: AnnaColors.bg, size: widget.size * 0.42),
          ),
        ],
      ),
    );
  }
}
