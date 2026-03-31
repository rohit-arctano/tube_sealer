import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/info_card.dart';

class CycleCounterCard extends StatelessWidget {
  final int today;
  final int total;
  const CycleCounterCard({super.key, required this.today, required this.total});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.cycleCounter,
      icon: Icons.pin_outlined,
      child: Row(
        children: [
          Expanded(
            child: _Counter(label: AppStrings.todayLabel, value: today),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFD0D8E0)),
          Expanded(
            child: _Counter(label: AppStrings.totalLabel, value: total),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  const _Counter({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: AppTextStyles.bigValue),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
