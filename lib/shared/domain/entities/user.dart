import '../enums/user_role.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.address,
    this.companyName,
    this.gstName,
    this.gstNumber,
    this.businessEmail,
    this.businessPhone,
  });

  final String id;
  final String name;
  final String phone;           // +91XXXXXXXXXX
  final String email;
  final UserRole role;
  final String? profileImageUrl;
  final String? address;
  // Driver-only fields
  final String? companyName;
  final String? gstName;
  final String? gstNumber;      // 27AABCS1429B1ZB
  final String? businessEmail;
  final String? businessPhone;

  bool get isDriver   => role == UserRole.driver;
  bool get isCustomer => role == UserRole.customer;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  User copyWith({
    String? id, String? name, String? phone, String? email, UserRole? role,
    String? profileImageUrl, String? address, String? companyName,
    String? gstName, String? gstNumber, String? businessEmail, String? businessPhone,
  }) => User(
    id: id ?? this.id, name: name ?? this.name, phone: phone ?? this.phone,
    email: email ?? this.email, role: role ?? this.role,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    address: address ?? this.address, companyName: companyName ?? this.companyName,
    gstName: gstName ?? this.gstName, gstNumber: gstNumber ?? this.gstNumber,
    businessEmail: businessEmail ?? this.businessEmail,
    businessPhone: businessPhone ?? this.businessPhone,
  );

  // ── JSON ────────────────────────────────────────────────────────────────

  factory User.fromJson(Map<String, dynamic> j) => User(
        id:              j['id']               as String,
        name:            j['name']             as String,
        phone:           j['phone']            as String,
        email:           j['email']            as String,
        role:            UserRole.values.byName(j['role'] as String),
        profileImageUrl: j['profile_image_url'] as String?,
        address:         j['address']           as String?,
        companyName:     j['company_name']      as String?,
        gstName:         j['gst_name']          as String?,
        gstNumber:       j['gst_number']        as String?,
        businessEmail:   j['business_email']    as String?,
        businessPhone:   j['business_phone']    as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':                id,
        'name':              name,
        'phone':             phone,
        'email':             email,
        'role':              role.name,
        'profile_image_url': profileImageUrl,
        'address':           address,
        'company_name':      companyName,
        'gst_name':          gstName,
        'gst_number':        gstNumber,
        'business_email':    businessEmail,
        'business_phone':    businessPhone,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
