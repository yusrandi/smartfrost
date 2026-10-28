import '../../domain/models/user_profile.dart';

/// Mock user profile dataset supporting dispatch and receiving operational roles.
abstract final class MockProfileData {
  static const UserProfile dispatchProfile = UserProfile(
    name: 'sasa',
    organization: 'Distributor A',
    location: 'Kabupaten Pangkep',
    accessRoleLabel: 'Akses Pengirim ikan',
    permissionsDescription: 'Membuat dan melihat pengiriman',
    syncStatusDescription: 'Online • data dapat disinkronkan',
    isOnline: true,
  );

  static const UserProfile receivingProfile = UserProfile(
    name: 'sasa',
    organization: 'Distributor B',
    location: 'Kabupaten Pangkep',
    accessRoleLabel: 'Akses Penerima ikan',
    permissionsDescription: 'Menerima dan memeriksa pengiriman',
    syncStatusDescription: 'Online • data dapat disinkronkan',
    isOnline: true,
  );
}
