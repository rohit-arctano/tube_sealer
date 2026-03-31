import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/constants/app_strings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/widgets/status_indicator.dart';
import '../../core/models/machine_status.dart';
import '../../core/models/user_role.dart';

/// Persistent top bar showing machine status, user role, and time.
class TopStatusBar extends StatelessWidget {
  final MachineStatus status;
  final UserRole userRole;

  const TopStatusBar({
    super.key,
    required this.status,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.statusBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(3),
            child: Image.asset(
              'assests/logo.png',
              semanticLabel: AppStrings.appTitle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.appTitle,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const Spacer(),
          StatusIndicator(status: status),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              userRole.label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
