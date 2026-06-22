import 'package:url_launcher/url_launcher.dart';

import 'phone_utils.dart';

/// Opens the phone dialer or WhatsApp for a contact number.
abstract final class ExternalLauncher {
  static bool hasCallableNumber(String dialCode, String localNumber) {
    final local = localNumber.replaceAll(RegExp(r'\D'), '');
    return local.length >= 6;
  }

  static Future<bool> dialPhone({
    required String dialCode,
    required String localNumber,
  }) async {
    if (!hasCallableNumber(dialCode, localNumber)) return false;

    final e164 = PhoneUtils.buildE164(dialCode, localNumber);
    return _launch(Uri.parse('tel:$e164'));
  }

  static Future<bool> openWhatsApp({
    required String dialCode,
    required String localNumber,
  }) async {
    if (!hasCallableNumber(dialCode, localNumber)) return false;

    final e164 = PhoneUtils.buildE164(dialCode, localNumber);
    final digits = e164.replaceAll(RegExp(r'[^\d]'), '');
    return _launch(
      Uri.parse('https://wa.me/$digits'),
      external: true,
    );
  }

  static Future<bool> _launch(Uri uri, {bool external = false}) async {
    try {
      return await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } catch (_) {
      return false;
    }
  }
}
