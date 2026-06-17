import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../res/font_res.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/profile/profile_image_content.dart';

/// Circular profile photo or initials — hero card on [AppProfileTab].
class ProfileAvatarDisplay extends StatelessWidget {
  const ProfileAvatarDisplay({
    super.key,
    required this.user,
    required this.size,
    this.borderWidth = 4,
    this.borderColor = const Color(0xFFEFF4FA),
  });

  final User user;
  final double size;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inner = size - borderWidth * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox(
          width: inner,
          height: inner,
          child: _buildContent(colors, inner),
        ),
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors, double inner) {
    return ProfileImageContent(
      imageReference: user.profileImageUrl,
      placeholder: _initials(colors, inner),
      fit: BoxFit.cover,
    );
  }

  Widget _initials(AppColorScheme colors, double inner) {
    return ColoredBox(
      color: colors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_EXTRABOLD,
            fontSize: (inner * 0.32).sp,
            fontWeight: FontWeight.w800,
            color: colors.primaryDark,
          ),
        ),
      ),
    );
  }
}
