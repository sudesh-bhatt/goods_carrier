import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';

/// Figma `more-2-fill` menu — Trip Details header (`1:2117`).
///
/// Vertical kebab (24×24, black) with a `#EDEDED` popup for **Report a trip?**.
class TripDetailMoreMenuButton extends StatelessWidget {
  const TripDetailMoreMenuButton({
    super.key,
    required this.reportLabel,
    required this.onReport,
  });

  final String reportLabel;
  final VoidCallback onReport;

  static const _menuBg = Color(0xFFEDEDED);
  static const _menuText = Color(0xFF191C1D);
  static const _iconColor = Color(0xFF000000);

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    final menuWidth = 110.w;
    final left = (offset.dx + box.size.width - menuWidth)
        .clamp(8.0, MediaQuery.sizeOf(context).width - menuWidth - 8);

    final action = await showMenu<String>(
      context: context,
      color: _menuBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      position: RelativeRect.fromLTRB(
        left,
        offset.dy + box.size.height + 4,
        left + menuWidth,
        offset.dy + box.size.height + 4,
      ),
      items: [
        _figmaMenuItem(value: 'report', label: reportLabel),
      ],
    );

    if (!context.mounted || action == null) return;
    if (action == 'report') onReport();
  }

  static PopupMenuItem<String> _figmaMenuItem({
    required String value,
    required String label,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: _menuText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (menuContext) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _openMenu(menuContext);
          },
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32.w,
            height: 32.w,
            child: Center(
              child: Icon(
                Icons.more_vert,
                size: 24.w,
                color: _iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
