import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/cycle_result.dart';

class ResultBanner extends StatelessWidget {
  final CycleResult result;
  const ResultBanner({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == CycleResult.none) return const SizedBox.shrink();

    final isPass = result == CycleResult.success;
    final icon = isPass ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            result.label,
            style: AppTextStyles.screenTitle,
          ),
        ],
      ),
    );
  }
}
