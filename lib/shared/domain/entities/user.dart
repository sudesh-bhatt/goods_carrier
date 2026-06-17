import '../enums/user_role.dart';

class User {
  const User({
    required this.id,
    this.name = '',
    required this.phone,
    this.countryCode = '+91',
    this.email = '',
    this.role,
    this.language,
    this.profileImageUrl,
    this.address,
    this.companyName,
    this.gstName,
    this.gstNumber,
    this.businessEmail,
    this.businessPhone,
    this.profileCompleted = false,
    this.agreementAccepted = false,
    this.status = 'active',
  });

  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String email;
  final UserRole? role;
  final String? language;
  final String? profileImageUrl;
  final String? address;
  final String? companyName;
  final String? gstName;
  final String? gstNumber;
  final String? businessEmail;
  final String? businessPhone;
  final bool profileCompleted;
  final bool agreementAccepted;
  final String status;

  bool get isDriver => role == UserRole.driver;
  bool get isCustomer => role == UserRole.customer;

  String get displayPhone {
    if (phone.startsWith('+')) return phone;
    if (countryCode.isNotEmpty) return '$countryCode$phone';
    return phone;
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? email,
    UserRole? role,
    String? language,
    String? profileImageUrl,
    String? address,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessPhone,
    bool? profileCompleted,
    bool? agreementAccepted,
    String? status,
    bool clearRole = false,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        email: email ?? this.email,
        role: clearRole ? null : (role ?? this.role),
        language: language ?? this.language,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        address: address ?? this.address,
        companyName: companyName ?? this.companyName,
        gstName: gstName ?? this.gstName,
        gstNumber: gstNumber ?? this.gstNumber,
        businessEmail: businessEmail ?? this.businessEmail,
        businessPhone: businessPhone ?? this.businessPhone,
        profileCompleted: profileCompleted ?? this.profileCompleted,
        agreementAccepted: agreementAccepted ?? this.agreementAccepted,
        status: status ?? this.status,
      );

  static String? _parsePrimaryAddress(Map<String, dynamic> json) {
    final text = json['primary_address_text'] as String?;
    if (text != null && text.isNotEmpty) return text;

    final primary = json['primary_address'];
    if (primary is String && primary.isNotEmpty) return primary;
    if (primary is Map<String, dynamic>) {
      final nested = primary['text'] as String? ??
          primary['primary_address_text'] as String? ??
          primary['address'] as String?;
      if (nested != null && nested.isNotEmpty) return nested;
    }

    final legacy = json['address'] as String?;
    if (legacy != null && legacy.isNotEmpty) return legacy;

    return null;
  }

  factory User.fromJson(Map<String, dynamic> j) {
    final rawId = j['id'];
    final id = rawId is int ? rawId.toString() : rawId as String? ?? '';

    final rawRole = j['role'] as String?;
    UserRole? role;
    if (rawRole != null && rawRole.isNotEmpty) {
      role = UserRole.values.byName(rawRole);
    }

    final rawPhone = j['phone'] as String? ?? '';
    final countryCode = j['country_code'] as String? ?? '+91';

    return User(
      id: id,
      name: j['name'] as String? ?? '',
      phone: rawPhone,
      countryCode: countryCode,
      email: j['email'] as String? ?? '',
      role: role,
      language: j['language'] as String?,
      profileImageUrl: j['profile_image_url'] as String? ?? j['avatar'] as String?,
      address: _parsePrimaryAddress(j),
      companyName: j['company_name'] as String?,
      gstName: j['gst_name'] as String?,
      gstNumber: j['gst_number'] as String?,
      businessEmail: j['business_email'] as String?,
      businessPhone: j['business_phone'] as String?,
      profileCompleted: j['profile_completed'] as bool? ?? false,
      agreementAccepted: j['agreement_accepted'] as bool? ?? false,
      status: j['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'country_code': countryCode,
        'email': email,
        if (role != null) 'role': role!.name,
        'language': language,
        'profile_image_url': profileImageUrl,
        'address': address,
        'company_name': companyName,
        'gst_name': gstName,
        'gst_number': gstNumber,
        'business_email': businessEmail,
        'business_phone': businessPhone,
        'profile_completed': profileCompleted,
        'agreement_accepted': agreementAccepted,
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
