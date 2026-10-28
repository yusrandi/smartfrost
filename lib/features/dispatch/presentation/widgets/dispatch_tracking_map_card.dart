import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../data/services/firestore_dispatch_service.dart';
import '../../domain/models/location_coordinate.dart';

/// Interactive real-time GPS sea logistics tracking map powered by Leaflet (FlutterMap),
/// visualizing origin pier, recipient destination, live vessel GPS coordinates from hardware sensor,
/// and live maritime distance telemetry.
class DispatchTrackingMapCard extends StatefulWidget {
  const DispatchTrackingMapCard({
    super.key,
    this.batchId = 'SFR-KK-201',
    this.originLocation = 'Dermaga Maccini Baji',
    this.destinationLocation = 'Pulau Jangang-Jangangan',
    this.receiverName = 'Andi Jemma',
    this.initialRealtimeDistance = '— km',
    this.initialLastUpdated = 'Belum tersedia',
    this.isGpsReceived = false,
    this.isSender = true,
  });

  final String batchId;
  final String originLocation;
  final String destinationLocation;
  final String receiverName;
  final String initialRealtimeDistance;
  final String initialLastUpdated;
  final bool isGpsReceived;
  final bool isSender;

  @override
  State<DispatchTrackingMapCard> createState() =>
      _DispatchTrackingMapCardState();
}

class _DispatchTrackingMapCardState extends State<DispatchTrackingMapCard> {
  late final MapController _mapController;

  // Subscriptions & Timers
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<DatabaseEvent>? _rtdbSubscription;
  Timer? _heartbeatTimer;

  // Hybrid Throttling State (Pengirim / Courier)
  Position? _latestPosition;
  Position? _lastSentPosition;
  DateTime? _lastSentTime;
  bool _mockGpsDetected = false;

  LatLng? _courierPosition;
  bool _isGpsActive = false;
  String _calculatedDistance = '— km';
  String _lastUpdatedText = 'Belum tersedia';
  double? _gpsAccuracy;
  bool _isMockedGpsActive = false;

  late final LocationCoordinate _originCoord;
  late final LocationCoordinate _destCoord;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final activeUser = AuthSession.instance.currentUser;
    _originCoord = LocationCoordinate.resolve(
      widget.originLocation,
      defaultLat: activeUser?.latitude ?? -4.8378,
      defaultLng: activeUser?.longitude ?? 119.5372,
    );
    _destCoord = LocationCoordinate.resolve(widget.destinationLocation);
    _calculatedDistance = widget.initialRealtimeDistance;
    _lastUpdatedText = widget.initialLastUpdated;
    _isGpsActive = widget.isGpsReceived;

    if (widget.isSender) {
      _initGpsTracking();
      // Heartbeat timer check setiap 10 detik
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _checkHeartbeat(),
      );
    } else {
      // Mode Penerima: Stream lokasi real-time dari Firebase Realtime Database
      _initReceiverStream();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _rtdbSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _initReceiverStream() {
    try {
      if (Firebase.apps.isEmpty || widget.batchId.trim().isEmpty) {
        _setFallbackMaritimePosition();
        return;
      }

      final ref =
          FirebaseDatabase.instance.ref('dispatches/${widget.batchId.trim()}');
      _rtdbSubscription = ref.onValue.listen((event) {
        if (!mounted) return;
        final val = event.snapshot.value;
        if (val is Map) {
          final lat = (val['currentLatitude'] as num?)?.toDouble();
          final lng = (val['currentLongitude'] as num?)?.toDouble();
          final dist = val['distanceRemaining']?.toString();
          final updatedTs = val['updatedAt'];
          final isMock = val['isMockedLocation'] == true;

          if (lat != null && lng != null) {
            final courierLatLng = LatLng(lat, lng);
            final distanceMeters = Geolocator.distanceBetween(
              lat,
              lng,
              _destCoord.latitude,
              _destCoord.longitude,
            );

            String timeStr = 'Baru saja';
            if (updatedTs is int) {
              final dt = DateTime.fromMillisecondsSinceEpoch(updatedTs);
              timeStr =
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WITA';
            }

            setState(() {
              _courierPosition = courierLatLng;
              _isGpsActive = true;
              _isMockedGpsActive = isMock;
              _calculatedDistance =
                  dist ?? '${(distanceMeters / 1000).toStringAsFixed(1)} km';
              _lastUpdatedText = timeStr;
            });
            return;
          }
        }
        _setFallbackMaritimePosition();
      }, onError: (_) {
        _setFallbackMaritimePosition();
      });
    } catch (_) {
      _setFallbackMaritimePosition();
    }
  }

  Future<void> _initGpsTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackMaritimePosition();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackMaritimePosition();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setFallbackMaritimePosition();
        return;
      }

      // Fetch immediate hardware or mock position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      _updatePosition(pos);

      // Listen for moving vessel updates
      // distanceFilter 5 meter agar pergerakan halus (termasuk joystick Fake GPS)
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        _updatePosition,
        onError: (_) => _setFallbackMaritimePosition(),
      );
    } catch (_) {
      _setFallbackMaritimePosition();
    }
  }

  void _updatePosition(Position pos) {
    if (!mounted) return;

    if (pos.isMocked) {
      _mockGpsDetected = true;
    }

    final isMock = pos.isMocked || _mockGpsDetected;

    // Anti-rubberbanding filter untuk Fake GPS:
    // Mencegah OS Android membocorkan koordinat BTS fisik asli yang melompat puluhan km
    if (isMock && _courierPosition != null) {
      final jumpMeters = Geolocator.distanceBetween(
        _courierPosition!.latitude,
        _courierPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (jumpMeters > 40000) {
        return;
      }
    }

    _latestPosition = pos;

    final courierLatLng = LatLng(pos.latitude, pos.longitude);
    final distanceMeters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      _destCoord.latitude,
      _destCoord.longitude,
    );

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WITA';

    // 1. Update UI Lokal Seketika (Lancar & Tanpa Delay)
    setState(() {
      _courierPosition = courierLatLng;
      _isGpsActive = true;
      _isMockedGpsActive = isMock;
      _gpsAccuracy = pos.accuracy;
      _calculatedDistance = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
      _lastUpdatedText = timeStr;
    });

    // 2. Evaluasi Hybrid Throttling sebelum kirim ke Firebase
    _evaluateAndSyncLocation(pos, isMock: isMock, now: now);
  }

  void _evaluateAndSyncLocation(
    Position pos, {
    required bool isMock,
    required DateTime now,
  }) {
    // Parameter adaptif:
    // - Fake GPS (Testing): Jarak 15m, throttle jeda 3 detik (responsif saat joystick digerakkan)
    // - Real GPS (Produksi): Jarak 50m, throttle jeda 10 detik (hemat baterai & kuota rute laut)
    final double minDistanceThreshold = isMock ? 15.0 : 50.0;
    final int minThrottleSeconds = isMock ? 3 : 10;

    if (_lastSentPosition == null || _lastSentTime == null) {
      _sendLocationToFirebase(pos, now, isMock: isMock);
      return;
    }

    final distanceMoved = Geolocator.distanceBetween(
      _lastSentPosition!.latitude,
      _lastSentPosition!.longitude,
      pos.latitude,
      pos.longitude,
    );
    final secondsElapsed = now.difference(_lastSentTime!).inSeconds;

    // Trigger: Berpindah melebihi jarak threshold DAN telah lewat jeda waktu throttle
    if (distanceMoved >= minDistanceThreshold &&
        secondsElapsed >= minThrottleSeconds) {
      _sendLocationToFirebase(pos, now, isMock: isMock);
    }
  }

  void _checkHeartbeat() {
    if (!mounted ||
        !widget.isSender ||
        _lastSentTime == null ||
        _latestPosition == null) {
      return;
    }

    final now = DateTime.now();
    final isMock = _latestPosition!.isMocked || _mockGpsDetected;
    // Timeout heartbeat: 45 detik untuk Fake GPS (mudah diverifikasi), 180 detik (3 menit) untuk produksi
    final int heartbeatTimeoutSeconds = isMock ? 45 : 180;

    final secondsElapsed = now.difference(_lastSentTime!).inSeconds;
    if (secondsElapsed >= heartbeatTimeoutSeconds) {
      _sendLocationToFirebase(
        _latestPosition!,
        now,
        isMock: isMock,
        isHeartbeat: true,
      );
    }
  }

  void _sendLocationToFirebase(
    Position pos,
    DateTime now, {
    required bool isMock,
    bool isHeartbeat = false,
  }) {
    _lastSentPosition = pos;
    _lastSentTime = now;

    FirestoreDispatchService.instance.updateDispatchLocation(
      batchId: widget.batchId,
      latitude: pos.latitude,
      longitude: pos.longitude,
      distanceRemaining: _calculatedDistance,
      isMocked: isMock,
      speed: pos.speed >= 0 ? pos.speed : null,
    );
  }

  void _setFallbackMaritimePosition() {
    if (!mounted) return;

    // Mid-sea navigation waypoint between origin and destination
    final midLat = (_originCoord.latitude + _destCoord.latitude) / 2;
    final midLng = (_originCoord.longitude + _destCoord.longitude) / 2;

    final distanceMeters = Geolocator.distanceBetween(
      midLat,
      midLng,
      _destCoord.latitude,
      _destCoord.longitude,
    );

    setState(() {
      _courierPosition = LatLng(midLat, midLng);
      if (_calculatedDistance == '— km') {
        _calculatedDistance =
            '${(distanceMeters / 1000).toStringAsFixed(1)} km';
        _lastUpdatedText = 'Estimasi Maritim';
      }
    });
  }

  void _recenterOnCourier() {
    if (_courierPosition != null) {
      _mapController.move(_courierPosition!, 12.0);
    }
  }

  void _fitAllWaypoints() {
    final points = [
      _originCoord.toLatLng,
      ?_courierPosition,
      _destCoord.toLatLng,
    ];

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final midSeaLat = (_originCoord.latitude + _destCoord.latitude) / 2;
    final midSeaLng = (_originCoord.longitude + _destCoord.longitude) / 2;
    final mapCenter = _courierPosition ?? LatLng(midSeaLat, midSeaLng);

    final routePolyline = [
      _originCoord.toLatLng,
      ?_courierPosition,
      _destCoord.toLatLng,
    ];

    // Status Badge Logic (Sender vs Receiver & Real vs Mock GPS)
    final String badgeText;
    final Color badgeBg;
    final Color badgeTextColor;

    if (widget.isSender) {
      if (_isGpsActive) {
        if (_isMockedGpsActive) {
          badgeText = 'Fake GPS (15m/3s)';
          badgeBg = const Color(0xFFFEF3C7);
          badgeTextColor = const Color(0xFFB45309);
        } else {
          badgeText = 'GPS Aktif (Pengirim)';
          badgeBg = AppColors.successBackground;
          badgeTextColor = AppColors.successText;
        }
      } else {
        badgeText = 'Menunggu GPS';
        badgeBg = const Color(0xFFF1F5F9);
        badgeTextColor = AppColors.textSecondary;
      }
    } else {
      if (_isGpsActive) {
        badgeText = _isMockedGpsActive
            ? 'Live Track (Simulasi)'
            : 'Live Tracking (Penerima)';
        badgeBg = const Color(0xFFE0F2FE);
        badgeTextColor = const Color(0xFF0369A1);
      } else {
        badgeText = 'Menghubungkan ke Kapal...';
        badgeBg = const Color(0xFFF1F5F9);
        badgeTextColor = AppColors.textSecondary;
      }
    }

    // Bottom Pill Status Logic
    final String statusPillText;
    if (widget.isSender) {
      if (_isGpsActive) {
        if (_isMockedGpsActive) {
          statusPillText = 'Fake GPS Aktif • Throttling 15m / 3s';
        } else {
          statusPillText = _gpsAccuracy != null
              ? 'GPS Aktif • Akurasi ±${_gpsAccuracy!.toStringAsFixed(0)}m'
              : 'GPS Perangkat Terhubung';
        }
      } else {
        statusPillText = 'Mencari sinyal GPS...';
      }
    } else {
      if (_isGpsActive) {
        statusPillText = 'Live RTDB • Memantau Pergerakan Kapal';
      } else {
        statusPillText = 'Menunggu sinyal posisi kapal...';
      }
    }

    // Footnote Logic
    final String footnoteText;
    if (widget.isSender) {
      if (_isMockedGpsActive) {
        footnoteText =
            'Mode Fake GPS terdeteksi: Throttling adaptif aktif (jarak 15m / jeda 3s, heartbeat 45s) agar responsif diuji coba menggunakan joystick.';
      } else {
        footnoteText =
            'Mode Pengirim: Throttling hybrid aktif (jarak 50m / jeda 10s, heartbeat 3 menit) menjaga baterai & kuota saat pelayaran laut.';
      }
    } else {
      footnoteText =
          'Mode Penerima: Posisi kapal diperbarui otomatis secara real-time via Firebase Realtime Database saat pengirim bergerak.';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: PELACAKAN PERJALANAN + Live Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PELACAKAN PERJALANAN',
                style: AppTypography.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: AppRadius.radiusPill,
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.caption.copyWith(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Lokasi GPS real-time',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Interactive Leaflet Map Container
          Container(
            height: 250,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFCCE8EB),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFB5DFE3), width: 1.2),
            ),
            child: Stack(
              children: [
                // 1. Free OpenStreetMap Leaflet Tile Layer
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 11.2,
                    minZoom: 8.0,
                    maxZoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.use.smartfrost',
                      tileBuilder: (context, widget, tile) {
                        return widget;
                      },
                    ),

                    // Maritime Polyline Route connecting Pier -> Ship -> Island
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePolyline,
                          strokeWidth: 3.5,
                          color: AppColors.primary,
                        ),
                      ],
                    ),

                    // Markers Layer: Origin, Live Courier Ship, and Destination
                    MarkerLayer(
                      markers: [
                        // Origin: Dermaga Maccini Baji
                        Marker(
                          point: _originCoord.toLatLng,
                          width: 140,
                          height: 54,
                          child: _MapWaypointMarker(
                            title: widget.originLocation,
                            icon: LucideIcons.anchor,
                            iconColor: const Color(0xFF0284C7),
                          ),
                        ),

                        // Destination: Pulau Jangang-Jangangan / Receiver
                        Marker(
                          point: _destCoord.toLatLng,
                          width: 160,
                          height: 54,
                          child: _MapWaypointMarker(
                            title: widget.destinationLocation,
                            subtitle: widget.receiverName,
                            icon: LucideIcons.mapPin,
                            iconColor: const Color(0xFF0D9488),
                          ),
                        ),

                        // Live User/Courier Vessel Position (HP Ini)
                        if (_courierPosition != null)
                          Marker(
                            point: _courierPosition!,
                            width: 130,
                            height: 60,
                            child: const _CourierVesselMarker(),
                          ),
                      ],
                    ),
                  ],
                ),

                // Floating Map Controls: Center Ship & Fit Bounds
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _MapActionButton(
                        icon: LucideIcons.navigation,
                        tooltip: 'Pusatkan ke Kapal',
                        onTap: _recenterOnCourier,
                      ),
                      const SizedBox(height: 6),
                      _MapActionButton(
                        icon: LucideIcons.maximize2,
                        tooltip: 'Lihat Semua Rute',
                        onTap: _fitAllWaypoints,
                      ),
                    ],
                  ),
                ),

                // Active Coordinates Pill (Center Bottom)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3F4A).withValues(alpha: 0.94),
                        borderRadius: AppRadius.radiusPill,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isGpsActive
                                ? LucideIcons.mapPinCheck
                                : LucideIcons.mapPinOff,
                            size: 13,
                            color: _isGpsActive
                                ? const Color(0xFF34D399)
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusPillText,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 2 Metric Counter Cards: Jarak real-time & Pembaruan terakhir
          Row(
            children: [
              // Metric 1: Jarak real-time
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jarak real-time',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculatedDistance,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Metric 2: Pembaruan terakhir
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pembaruan terakhir',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastUpdatedText,
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Footnote: Sensor GPS notice
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.info,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  footnoteText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Floating action button on map for zoom / recentering
class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}

/// Custom Pin marker widget with label pill
class _MapWaypointMarker extends StatelessWidget {
  const _MapWaypointMarker({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }
}

/// Animated pulsating ship marker representing the courier's live phone GPS
class _CourierVesselMarker extends StatelessWidget {
  const _CourierVesselMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            'Kapal Kurir (Anda)',
            style: AppTypography.badge.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF0E8AA7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E8AA7).withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.ship,
            size: 11,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
