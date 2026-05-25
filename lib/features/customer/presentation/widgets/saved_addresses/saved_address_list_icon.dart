import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../shared/domain/enums/saved_address_label.dart';

/// List-card icon box — Figma `1:3130` (48×48, 12px radius, outlined glyphs).
class SavedAddressListIcon extends StatelessWidget {
  const SavedAddressListIcon({
    super.key,
    required this.label,
  });

  final SavedAddressLabel label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = label.listIconColors;
    final (iconW, iconH) = label.listIconSize;

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Icon(
        label.listIcon,
        size: iconW.w,
        color: fg,
      ),
    );
  }
}
