import '../../shared/domain/entities/user.dart';
import '../../shared/domain/enums/user_role.dart';

class DummyUser {
  DummyUser._();

  static const customer = User(
    id: 'USR-0001',
    name: 'Arjun Sharma',
    phone: '+919876543210',
    email: 'arjun.sharma@email.com',
    role: UserRole.customer,
    address: 'Bandra West, Mumbai, MH',
  );

  static const driver = User(
    id: 'USR-0002',
    name: 'Vikram Singh Rajput',
    phone: '+919988776655',
    email: 'vikram.singh@email.com',
    role: UserRole.driver,
    companyName: 'Singh Logistics Pvt. Ltd.',
    gstName: 'SINGH LOGISTICS PVT LTD',
    gstNumber: '27AABCS1429B1ZB',
    businessEmail: 'accounts@singhlogistics.com',
    businessPhone: '+912244556677',
  );
}
