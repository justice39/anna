import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class AnnaTabBar extends StatelessWidget {
  const AnnaTabBar({
    super.key,
    required this.current,
    required this.onChange,
  });

  final int current;
  final ValueChanged<int> onChange;

  static const items = [
    (Icons.home_outlined, 'TODAY'),
    (Icons.list_alt, 'ALL'),
    (Icons.mic_none, 'ANNA'),
    (Icons.settings_outlined, 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AnnaColors.bg.withOpacity(0.85),
        border: const Border(top: BorderSide(color: AnnaColors.line)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == current;
          return Expanded(
            child: InkWell(
              onTap: () => onChange(i),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (active)
                    Positioned(
                      top: 0,
                      left: 24,
                      right: 24,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AnnaColors.gold,
                          boxShadow: [
                            BoxShadow(
                                color: AnnaColors.goldGlow, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1,
                          size: 22,
                          color: active
                              ? AnnaColors.gold
                              : AnnaColors.textSoft),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: AnnaText.meta.copyWith(
                          fontSize: 8,
                          color:
                              active ? AnnaColors.gold : AnnaColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
