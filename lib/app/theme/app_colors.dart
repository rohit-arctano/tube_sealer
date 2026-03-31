import 'package:flutter/material.dart';
import '../../core/models/machine_status.dart';

/// Monochrome industrial palette based on the PNG reference screens.
class AppColors {
  AppColors._();

  static const primary = Color(0xFFFFFFFF);
  static const primaryLight = Color(0xFFF3F3F3);
  static const primaryDark = Color(0xFF000000);

  static const background = Color(0xFF000000);
  static const surface = Color(0xFF000000);
  static const surfaceVariant = Color(0xFF111111);

  static const ready = Color(0xFFFFFFFF);
  static const running = Color(0xFFE6E6E6);
  static const warning = Color(0xFFD9D9D9);
  static const error = Color(0xFFFFFFFF);
  static const maintenance = Color(0xFFBDBDBD);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFE0E0E0);
  static const textOnPrimary = Color(0xFF000000);
  static const textOnDark = Color(0xFFFFFFFF);

  static const divider = Color(0xFFFFFFFF);
  static const disabled = Color(0xFF666666);
  static const success = Color(0xFFFFFFFF);
  static const fail = Color(0xFFD0D0D0);

  static Color fromStatus(MachineStatus status) {
    switch (status) {
      case MachineStatus.ready:
        return ready;
      case MachineStatus.running:
        return running;
      case MachineStatus.warning:
        return warning;
      case MachineStatus.error:
        return error;
      case MachineStatus.maintenance:
        return maintenance;
    }
  }
}
