import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared type scale tuned to the industrial reference screens.
class AppTextStyles {
  AppTextStyles._();

  static const _fontFamily = 'monospace';

  static const _screenTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );

  static const _sectionTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const _bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const _bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const _caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const _statusLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const _bigValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const _buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle screenTitleFor(Color color) => _screenTitle.copyWith(color: color);
  static TextStyle sectionTitleFor(Color color) => _sectionTitle.copyWith(color: color);
  static TextStyle bodyLargeFor(Color color) => _bodyLarge.copyWith(color: color);
  static TextStyle bodyMediumFor(Color color) => _bodyMedium.copyWith(color: color);
  static TextStyle captionFor(Color color) => _caption.copyWith(color: color);
  static TextStyle statusLabelFor(Color color) => _statusLabel.copyWith(color: color);
  static TextStyle bigValueFor(Color color) => _bigValue.copyWith(color: color);
  static TextStyle buttonLabelFor(Color color) => _buttonLabel.copyWith(color: color);

  static TextStyle get screenTitle => screenTitleFor(AppColors.textPrimary);
  static TextStyle get sectionTitle => sectionTitleFor(AppColors.textPrimary);
  static TextStyle get bodyLarge => bodyLargeFor(AppColors.textPrimary);
  static TextStyle get bodyMedium => bodyMediumFor(AppColors.textPrimary);
  static TextStyle get caption => captionFor(AppColors.textSecondary);
  static TextStyle get statusLabel => statusLabelFor(AppColors.textPrimary);
  static TextStyle get bigValue => bigValueFor(AppColors.textPrimary);
  static TextStyle get buttonLabel => buttonLabelFor(AppColors.textPrimary);
}
