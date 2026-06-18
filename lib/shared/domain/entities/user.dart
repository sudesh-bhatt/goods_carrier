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
    this.city,
    this.postalCode,
    this.fullAddress,
    this.companyName,
    this.gstName,
    this.gstNumber,
    this.businessEmail,
    this.businessCountryCode,
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
  final String? city;
  final String? postalCode;
  final String? fullAddress;
  final String? companyName;
  final String? gstName;
  final String? gstNumber;
  final String? businessEmail;
  final String? businessCountryCode;
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
    String? city,
    String? postalCode,
    String? fullAddress,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessCountryCode,
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
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        fullAddress: fullAddress ?? this.fullAddress,
        companyName: companyName ?? this.companyName,
        gstName: gstName ?? this.gstName,
        gstNumber: gstNumber ?? this.gstNumber,
        businessEmail: businessEmail ?? this.businessEmail,
        businessCountryCode: businessCountryCode ?? this.businessCountryCode,
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

  static String? _parseDriverAddress(Map<String, dynamic> json) {
    final fullAddress = json['full_address'] as String?;
    final city = json['city'] as String?;
    final postal = json['postal_code'] as String?;
    if ((fullAddress == null || fullAddress.isEmpty) &&
        (city == null || city.isEmpty) &&
        (postal == null || postal.isEmpty)) {
      return null;
    }

    final parts = <String>[];
    if (fullAddress != null && fullAddress.isNotEmpty) parts.add(fullAddress);
    final cityPostal = [
      if (city != null && city.isNotEmpty) city,
      if (postal != null && postal.isNotEmpty) postal,
    ].join(', ');
    if (cityPostal.isNotEmpty) parts.add(cityPostal);
    return parts.join('\n');
  }

  static Map<String, dynamic> _mergeDriverProfile(Map<String, dynamic> json) {
    final driverProfile = json['driver_profile'];
    if (driverProfile is! Map<String, dynamic>) return json;
    return {...json, ...driverProfile};
  }

  static String? _parseBusinessPhone(Map<String, dynamic> json) {
    final phone = json['business_phone'] as String?;
    if (phone == null || phone.isEmpty) return null;
    if (json['business_country_code'] != null) {
      return phone.replaceAll(RegExp(r'\D'), '');
    }
    if (phone.startsWith('+')) return phone;

    final code = json['business_country_code'] as String? ?? '';
    if (code.isNotEmpty) return '$code$phone';
    return phone;
  }

  factory User.fromJson(Map<String, dynamic> j) {
    final nested = j['user'];
    if (nested is Map<String, dynamic>) {
      return User.fromJson(nested);
    }

    final profile = _mergeDriverProfile(j);
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
      name: j['name'] as String? ?? j['full_name'] as String? ?? '',
      phone: rawPhone,
      countryCode: countryCode,
      email: j['email'] as String? ?? '',
      role: role,
      language: j['language'] as String?,
      profileImageUrl: j['profile_image_url'] as String? ?? j['avatar'] as String?,
      address: _parsePrimaryAddress(j) ?? _parseDriverAddress(profile),
      city: profile['city'] as String?,
      postalCode: profile['postal_code'] as String?,
      fullAddress: profile['full_address'] as String?,
      companyName: profile['company_name'] as String?,
      gstName: profile['gst_name'] as String?,
      gstNumber: profile['gst_number'] as String?,
      businessEmail: profile['business_email'] as String?,
      businessCountryCode: profile['business_country_code'] as String?,
      businessPhone: _parseBusinessPhone(profile),
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
        'city': city,
        'postal_code': postalCode,
        'full_address': fullAddress,
        'company_name': companyName,
        'gst_name': gstName,
        'gst_number': gstNumber,
        'business_email': businessEmail,
        'business_country_code': businessCountryCode,
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
