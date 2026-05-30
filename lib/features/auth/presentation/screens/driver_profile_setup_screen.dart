import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';
import '../widgets/driver_profile_form_widgets.dart';

/// Driver profile setup — matches Figma Profile Setup (Driver) node 1-661.
class DriverProfileSetupScreen extends ConsumerStatefulWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  ConsumerState<DriverProfileSetupScreen> createState() =>
      _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends ConsumerState<DriverProfileSetupScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _gstNameCtrl = TextEditingController();
  final _gstNumberCtrl = TextEditingController();
  final _businessEmailCtrl = TextEditingController();
  final _businessPhoneCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final raw = ref.read(authProvider).phoneNumber;
    _phoneCtrl.text = _formatPhoneDisplay(raw);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _addressCtrl.dispose();
    _companyCtrl.dispose();
    _gstNameCtrl.dispose();
    _gstNumberCtrl.dispose();
    _businessEmailCtrl.dispose();
    _businessPhoneCtrl.dispose();
    super.dispose();
  }

  String _formatPhoneDisplay(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (local.length == 10) return '+91 $local';
    }
    if (raw.startsWith('+')) return raw;
    return '+91 $raw';
  }

  String _buildFullAddress() {
    final parts = <String>[];
    final street = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final postal = _postalCtrl.text.trim();
    if (street.isNotEmpty) parts.add(street);
    if (city.isNotEmpty || postal.isNotEmpty) {
      parts.add([city, postal].where((s) => s.isNotEmpty).join(', '));
    }
    return parts.join('\n');
  }

  String? _optionalGst(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.gstNumber(value);
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final businessPhone = _businessPhoneCtrl.text.trim();
    await ref.read(authProvider.notifier).submitDriverProfile(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          address: _buildFullAddress(),
          companyName:
              _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
          gstName:
              _gstNameCtrl.text.trim().isEmpty ? null : _gstNameCtrl.text.trim(),
          gstNumber: _gstNumberCtrl.text.trim().isEmpty
              ? null
              : _gstNumberCtrl.text.trim(),
          businessEmail: _businessEmailCtrl.text.trim().isEmpty
              ? null
              : _businessEmailCtrl.text.trim(),
          businessPhone:
              businessPhone.isEmpty ? null : '+91$businessPhone',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: kDriverProfileBackground,
      appBar: FlowScreenAppBar(
        title: l10n.driverProfileCompleteTitle,
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Personal details ──────────────────────────────────────
                DriverProfilePersonalSectionHeader(
                  title: l10n.driverProfilePersonalDetails,
                ),
                SizedBox(height: 12.h),
                DriverProfileSectionCard(
                  child: Column(
                    children: [
                      DriverProfilePersonalField(
                        label: l10n.profileName,
                        hint: 'e.g. Vikram Singh',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        validator: (v) => Validators.required(v, l10n.profileName),
                      ),
                      SizedBox(height: 16.h),
                      DriverProfilePersonalField(
                        label: l10n.profilePhone,
                        controller: _phoneCtrl,
                        readOnly: true,
                        suffix: Icon(
                          Icons.lock_outline,
                          size: 10.w,
                          color: const Color(0xFF594136),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      DriverProfilePersonalField(
                        label: l10n.profileEmailOptional,
                        hint: 'john@carrier.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.email(v);
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DriverProfilePersonalField(
                              label: l10n.profileCity,
                              hint: 'Ahmedabad',
                              controller: _cityCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DriverProfilePersonalField(
                              label: l10n.profilePostalCode,
                              hint: '001238',
                              controller: _postalCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      DriverProfileAddressField(
                        label: l10n.profileFullAddress,
                        hint: 'Street number, building...',
                        controller: _addressCtrl,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.required(v, l10n.profileFullAddress),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Business details ──────────────────────────────────────
                DriverProfileBusinessSectionHeader(
                  title: l10n.driverProfileBusinessDetails,
                ),
                SizedBox(height: 16.h),
                DriverProfileSectionCard(
                  borderRadius: 16,
                  gap: 20,
                  useBusinessShadow: true,
                  child: Column(
                    children: [
                      DriverProfileBusinessField(
                        label: l10n.profileCompanyName,
                        hint: 'Enter legally registered name',
                        controller: _companyCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileGstName,
                        hint: 'GST name',
                        controller: _gstNameCtrl,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileGstNumberOptional,
                        hint: '22AAAAA0000A1Z5',
                        controller: _gstNumberCtrl,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        validator: _optionalGst,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileBusinessEmail,
                        hint: 'name@company.com',
                        controller: _businessEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.email(v);
                        },
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessPhoneField(
                        label: l10n.profileBusinessPhone,
                        hint: '00000 00000',
                        controller: _businessPhoneCtrl,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.phoneForCountry('+91', v);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── CTA ───────────────────────────────────────────────────
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 274.w,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colors.onPrimary,
                                ),
                              )
                            : Text(
                                l10n.driverProfileCompleteButton,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 28 / 18,
                                  color: colors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
