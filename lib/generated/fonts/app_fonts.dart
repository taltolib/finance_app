import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';

class AppFonts {
  AppFonts._();

  static final mulish = _TextStyleMulish();
}

class _TextStyleMulish {
  static const String _fontFamily = 'Mulish';

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textBlack,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Size 10
  TextStyle s10w200({Color color = AppColors.textBlack}) => _base(size: 10, weight: FontWeight.w200, color: color);
  TextStyle s10w300({Color color = AppColors.textBlack}) => _base(size: 10, weight: FontWeight.w300, color: color);
  TextStyle s10w400({Color color = AppColors.textBlack}) => _base(size: 10, weight: FontWeight.w400, color: color);

  // Size 11
  TextStyle s11w400({Color color = AppColors.textBlack}) => _base(size: 11, weight: FontWeight.w400, color: color);
  TextStyle s11w600({Color color = AppColors.textBlack}) => _base(size: 11, weight: FontWeight.w600, color: color);

  // Size 12
  TextStyle s12w400({Color color = AppColors.textBlack}) => _base(size: 12, weight: FontWeight.w400, color: color);
  TextStyle s12w500({Color color = AppColors.textBlack}) => _base(size: 12, weight: FontWeight.w500, color: color);
  TextStyle s12w600({Color color = AppColors.textBlack}) => _base(size: 12, weight: FontWeight.w600, color: color);
  TextStyle s12w700({Color color = AppColors.textBlack}) => _base(size: 12, weight: FontWeight.w700, color: color);

  // Size 14
  TextStyle s14w400({Color color = AppColors.textBlack}) => _base(size: 14, weight: FontWeight.w400, color: color);
  TextStyle s14w500({Color color = AppColors.textBlack}) => _base(size: 14, weight: FontWeight.w500, color: color);
  TextStyle s14w600({Color color = AppColors.textBlack}) => _base(size: 14, weight: FontWeight.w600, color: color);
  TextStyle s14w700({Color color = AppColors.textBlack}) => _base(size: 14, weight: FontWeight.w700, color: color);

  // Size 15
  TextStyle s15w400({Color color = AppColors.textBlack}) => _base(size: 15, weight: FontWeight.w400, color: color);
  TextStyle s15w500({Color color = AppColors.textBlack}) => _base(size: 15, weight: FontWeight.w500, color: color);
  TextStyle s15w600({Color color = AppColors.textBlack}) => _base(size: 15, weight: FontWeight.w600, color: color);

  // Size 16
  TextStyle s16w400({Color color = AppColors.textBlack}) => _base(size: 16, weight: FontWeight.w400, color: color);
  TextStyle s16w500({Color color = AppColors.textBlack}) => _base(size: 16, weight: FontWeight.w500, color: color);
  TextStyle s16w600({Color color = AppColors.textBlack}) => _base(size: 16, weight: FontWeight.w600, color: color);
  TextStyle s16w700({Color color = AppColors.textBlack}) => _base(size: 16, weight: FontWeight.w700, color: color);

  // Size 18
  TextStyle s18w400({Color color = AppColors.textBlack}) => _base(size: 18, weight: FontWeight.w400, color: color);
  TextStyle s18w500({Color color = AppColors.textBlack}) => _base(size: 18, weight: FontWeight.w500, color: color);
  TextStyle s18w600({Color color = AppColors.textBlack}) => _base(size: 18, weight: FontWeight.w600, color: color);
  TextStyle s18w700({Color color = AppColors.textBlack}) => _base(size: 18, weight: FontWeight.w700, color: color);

  // Size 20
  TextStyle s20w500({Color color = AppColors.textBlack}) => _base(size: 20, weight: FontWeight.w500, color: color);
  TextStyle s20w700({Color color = AppColors.textBlack}) => _base(size: 20, weight: FontWeight.w700, color: color);

  // Size 22
  TextStyle s22w600({Color color = AppColors.textBlack}) => _base(size: 22, weight: FontWeight.w600, color: color);

  // Size 24
  TextStyle s24w400({Color color = AppColors.textBlack}) => _base(size: 24, weight: FontWeight.w400, color: color);
  TextStyle s24w700({Color color = AppColors.textBlack}) => _base(size: 24, weight: FontWeight.w700, color: color);

  // Size 26
  TextStyle s26w700({Color color = AppColors.textBlack}) => _base(size: 26, weight: FontWeight.w700, color: color);

  // Size 28
  TextStyle s28w700({Color color = AppColors.textBlack}) => _base(size: 28, weight: FontWeight.w700, color: color);

  // Size 30
  TextStyle s30w700({Color color = AppColors.textBlack}) => _base(size: 30, weight: FontWeight.w700, color: color);

  // Size 32
  TextStyle s32w700({Color color = AppColors.textBlack}) => _base(size: 32, weight: FontWeight.w700, color: color);

  // Size 40
  TextStyle s40w700({Color color = AppColors.textBlack}) => _base(size: 40, weight: FontWeight.w700, color: color);
}
