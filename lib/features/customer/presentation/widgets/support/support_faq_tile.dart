import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/mixins/safe_set_state_mixin.dart';
import 'support_center_tokens.dart';
import 'support_faq_chevron.dart';

/// Expandable FAQ row — Figma `1:3571` (24px padding, 12×7.4 chevron, space-between).
class SupportFaqTile extends StatefulWidget {
  const SupportFaqTile({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<SupportFaqTile> createState() => _SupportFaqTileState();
}

class _SupportFaqTileState extends State<SupportFaqTile>
    with SafeSetStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1,
      child: Material(
        color: SupportCenterTokens.faqFill,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            safeSetState(() => _expanded = !_expanded);
          },
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: SupportCenterTokens.faqQuestion(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SupportFaqChevron(expanded: _expanded),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.answer,
                              style: SupportCenterTokens.faqAnswer(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
