import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../res/font_res.dart';
import 'app_bottom_sheet.dart';
import 'app_modal_bottom_sheet.dart';

/// Single selectable row for [AppPickerBottomSheet].
class AppPickerItem<T> {
  const AppPickerItem({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

/// Picker bottom sheet — Figma bottom sheet container (`1:2310`).
class AppPickerBottomSheet {
  AppPickerBottomSheet._();

  static const _titleColor = Color(0xFF191C1D);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<AppPickerItem<T>> items,
  }) {
    return AppModalBottomSheet.show<T>(
      context: context,
      builder: (_) => _AppPickerSheetBody<T>(title: title, items: items),
    );
  }
}

class _AppPickerSheetBody<T> extends StatelessWidget {
  const _AppPickerSheetBody({
    required this.title,
    required this.items,
  });

  final String title;
  final List<AppPickerItem<T>> items;

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        MediaQuery.sizeOf(context).height * AppBottomSheetTokens.maxHeightFraction;

    return AppBottomSheetContainer(
      maxHeight: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppPickerBottomSheet._titleColor,
            ),
          ),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context, item.value);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_MEDIUM,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPickerBottomSheet._titleColor,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              item.subtitle!,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_REGULAR,
                                fontSize: 13.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
