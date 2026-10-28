/// Domain model for the user and distributor operational profile.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.organization,
    required this.location,
    required this.accessRoleLabel,
    required this.permissionsDescription,
    this.email = 'sasa@smartfrost.id',
    this.storeLocation = 'Dermaga Maccini Baji',
    this.latitude = -4.8378,
    this.longitude = 119.5372,
    this.syncStatusDescription = 'Online • data dapat disinkronkan',
    this.isOnline = true,
    this.phoneNumber = '+62 812-4210-9876',
  });

  final String name;
  final String organization;
  final String location;
  final String accessRoleLabel;
  final String permissionsDescription;
  final String email;
  final String storeLocation;
  final double latitude;
  final double longitude;
  final String syncStatusDescription;
  final bool isOnline;
  final String phoneNumber;

  String get organizationLocation => '$organization • $location';

  String get coordinatesFormatted =>
      '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
}
