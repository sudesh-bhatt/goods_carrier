import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizeExt on num {
  /// Scales to screen WIDTH — use for horizontal sizes, left/right padding, widths.
  double get w => ScreenUtil().setWidth(this);

  /// Scales to screen HEIGHT — use for vertical spacing, button heights.
  double get h => ScreenUtil().setHeight(this);

  /// Font size — scales with screen and respects accessibility scale (clamped in app.dart).
  double get sp => ScreenUtil().setSp(this);

  /// Radius — uses smaller of w/h to avoid distortion on unusual aspect ratios.
  double get r => ScreenUtil().radius(this);
}
