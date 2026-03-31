import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/info_card.dart';

class LiveParameterCard extends StatelessWidget {
  final double temperature;
  final double targetTemperature;
  const LiveParameterCard({
    super.key,
    required this.temperature,
    required this.targetTemperature,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.liveParameters,
      icon: Icons.thermostat,
      accentColor: AppColors.warning,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.temperature, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: AppTextStyles.bigValue,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Target', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                '${targetTemperature.toStringAsFixed(0)}°C',
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
