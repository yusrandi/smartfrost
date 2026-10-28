import 'package:latlong2/latlong.dart';

/// Geocoded geographical coordinates representation for maritime ports & islands.
class LocationCoordinate {
  const LocationCoordinate({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;

  LatLng get toLatLng => LatLng(latitude, longitude);

  /// Predefined maritime waypoint coordinates for Pangkep and South Sulawesi cold-chain routes.
  static const Map<String, LocationCoordinate> predefined = {
    'Dermaga Maccini Baji': LocationCoordinate(
      name: 'Dermaga Maccini Baji',
      latitude: -4.8378,
      longitude: 119.5372,
    ),
    'Dermaga Biringkassi': LocationCoordinate(
      name: 'Dermaga Biringkassi',
      latitude: -4.7958,
      longitude: 119.5085,
    ),
    'Pulau Karanrang': LocationCoordinate(
      name: 'Pulau Karanrang',
      latitude: -4.8631,
      longitude: 119.3872,
    ),
    'Pulau Sanane': LocationCoordinate(
      name: 'Pulau Sanane',
      latitude: -4.8986,
      longitude: 119.3361,
    ),
    'Pulau Jangan-Jangangan': LocationCoordinate(
      name: 'Pulau Jangan-Jangangan',
      latitude: -4.8620,
      longitude: 119.3510,
    ),
    'Pulau Jangang-Jangangan': LocationCoordinate(
      name: 'Pulau Jangang-Jangangan',
      latitude: -4.8620,
      longitude: 119.3510,
    ),
    'Pulau Kalupu': LocationCoordinate(
      name: 'Pulau Kalupu',
      latitude: -4.8450,
      longitude: 119.3100,
    ),
    'Pulau Kapoposang': LocationCoordinate(
      name: 'Pulau Kapoposang',
      latitude: -4.6958,
      longitude: 118.9536,
    ),
    'Pulau Balang Lompo': LocationCoordinate(
      name: 'Pulau Balang Lompo',
      latitude: -4.9350,
      longitude: 119.3620,
    ),
    'Pelabuhan Paotere': LocationCoordinate(
      name: 'Pelabuhan Paotere',
      latitude: -5.1146,
      longitude: 119.4190,
    ),
    'Pelabuhan Bira': LocationCoordinate(
      name: 'Pelabuhan Bira',
      latitude: -5.6120,
      longitude: 120.4570,
    ),
  };

  /// Resolves known port/island coordinates with maritime fallback
  static LocationCoordinate resolve(
    String name, {
    double defaultLat = -4.8378,
    double defaultLng = 119.5372,
  }) {
    return predefined[name] ??
        LocationCoordinate(
          name: name,
          latitude: defaultLat,
          longitude: defaultLng,
        );
  }
}
