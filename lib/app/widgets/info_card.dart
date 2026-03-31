import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// Reusable card with a title row and body content.
class InfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final Color? accentColor;

  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                ],
                Text(title, style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
