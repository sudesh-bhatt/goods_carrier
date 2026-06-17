class OtpSession {
  const OtpSession({
    required this.referenceId,
    required this.otpExpiresIn,
    required this.resendRemaining,
    this.isExistingUser = false,
  });

  final String referenceId;
  final int otpExpiresIn;
  final int resendRemaining;
  final bool isExistingUser;

  factory OtpSession.fromJson(Map<String, dynamic> json) => OtpSession(
        referenceId: json['reference_id'] as String,
        otpExpiresIn: (json['otp_expires_in'] as num?)?.toInt() ?? 300,
        resendRemaining: (json['resend_remaining'] as num?)?.toInt() ?? 0,
        isExistingUser: json['is_existing_user'] as bool? ?? false,
      );
}
