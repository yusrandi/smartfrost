import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../dispatch/data/services/firestore_dispatch_service.dart';
import '../../../dispatch/data/services/firestore_master_data_service.dart';
import '../../../dispatch/domain/models/location_coordinate.dart';
import '../../../profile/domain/models/user_profile.dart';

/// Centralized session management for authenticated distributor and recipient users,
/// storing distributor credentials and geographical store/pier coordinates for live tracking.
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  double get distributorLatitude => _currentUser?.latitude ?? -4.8378;
  double get distributorLongitude => _currentUser?.longitude ?? 119.5372;

  /// Sync active session with Firebase Auth on application boot / restart
  Future<void> syncWithFirebaseAuth() async {
    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }
      final email = fbUser.email ?? '';
      if (email.isNotEmpty) {
        await restoreFromEmail(email, uid: fbUser.uid);
      }
    } catch (e) {
      debugPrint('AuthSession syncWithFirebaseAuth notice: $e');
    }
  }

  /// Restore user profile matching authenticated email address
  Future<void> restoreFromEmail(String email, {String? uid}) async {
    final matchedDist = _matchDistributorByEmail(email);
    if (matchedDist != null) {
      _currentUser = UserProfile(
        name: matchedDist.name,
        organization: matchedDist.organization,
        location: 'Kabupaten Pangkep',
        email: matchedDist.email,
        storeLocation: matchedDist.storeLocation,
        latitude: matchedDist.latitude,
        longitude: matchedDist.longitude,
        accessRoleLabel: 'Akses Pengirim ikan',
        permissionsDescription: 'Membuat dan melihat pengiriman',
      );
      notifyListeners();
      return;
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        final cleanDocId = (uid ?? email).replaceAll('.', '_');
        final snap = await FirebaseDatabase.instance.ref('users/$cleanDocId').get();
        if (snap.exists && snap.value is Map) {
          final data = Map<String, dynamic>.from(snap.value as Map);
          _currentUser = UserProfile(
            name: data['name'] ?? _formatNameFromEmail(email),
            organization: data['organization'] ?? 'Distributor Pangkep',
            location: data['location'] ?? 'Kabupaten Pangkep',
            email: email,
            storeLocation: data['storeLocation'] ?? 'Dermaga Maccini Baji',
            latitude: (data['latitude'] as num?)?.toDouble() ?? -4.8378,
            longitude: (data['longitude'] as num?)?.toDouble() ?? 119.5372,
            accessRoleLabel: data['accessRoleLabel'] ?? 'Akses Pengirim ikan',
            permissionsDescription:
                data['permissionsDescription'] ?? 'Membuat dan melihat pengiriman',
          );
          notifyListeners();
          return;
        }
      }
    } catch (_) {}

    final formattedName = _formatNameFromEmail(email);
    _currentUser = UserProfile(
      name: formattedName,
      organization: formattedName,
      location: 'Kabupaten Pangkep',
      email: email,
      storeLocation: 'Dermaga Maccini Baji',
      latitude: -4.8378,
      longitude: 119.5372,
      accessRoleLabel: 'Akses Pengirim ikan',
      permissionsDescription: 'Membuat dan melihat pengiriman',
    );
    notifyListeners();
  }

  void loginWithGoogle({
    required String name,
    required String email,
    String? storeLocation,
    double? latitude,
    double? longitude,
  }) {
    final defaultStore = (storeLocation != null && storeLocation.isNotEmpty)
        ? storeLocation
        : 'Dermaga Maccini Baji';
    final defaultCoord = LocationCoordinate.resolve(defaultStore);

    _currentUser = UserProfile(
      name: name.isNotEmpty ? name : 'Distributor Pangkep',
      organization: name.isNotEmpty ? name : 'Distributor Pangkep',
      location: 'Kabupaten Pangkep',
      email: email,
      storeLocation: defaultStore,
      latitude: latitude ?? defaultCoord.latitude,
      longitude: longitude ?? defaultCoord.longitude,
      accessRoleLabel: 'Akses Pengirim ikan',
      permissionsDescription: 'Membuat dan melihat pengiriman',
    );
    notifyListeners();
    FirestoreDispatchService.instance.saveUserProfile(_currentUser!);
  }

  Future<void> login({
    required String email,
    required String password,
    String? name,
    String? organization,
    String? storeLocation,
    int roleIndex = 0,
    double? latitude,
    double? longitude,
    String? uid,
  }) async {
    final isDispatch = roleIndex == 0;
    final matchedDist = _matchDistributorByEmail(email);

    final resolvedName = name ??
        matchedDist?.name ??
        (email.isNotEmpty
            ? _formatNameFromEmail(email)
            : (isDispatch ? 'Pengirim' : 'Penerima'));

    final resolvedStore = storeLocation ??
        matchedDist?.storeLocation ??
        'Dermaga Maccini Baji';

    final resolvedOrg = organization ??
        matchedDist?.organization ??
        resolvedName;

    final defaultCoord = LocationCoordinate.resolve(resolvedStore);
    final resolvedLat =
        latitude ?? matchedDist?.latitude ?? defaultCoord.latitude;
    final resolvedLng =
        longitude ?? matchedDist?.longitude ?? defaultCoord.longitude;

    _currentUser = UserProfile(
      name: resolvedName,
      organization: resolvedOrg,
      location: 'Kabupaten Pangkep',
      email: email,
      storeLocation: resolvedStore,
      latitude: resolvedLat,
      longitude: resolvedLng,
      accessRoleLabel:
          isDispatch ? 'Akses Pengirim ikan' : 'Akses Penerima ikan',
      permissionsDescription: isDispatch
          ? 'Membuat dan melihat pengiriman'
          : 'Menerima dan memeriksa pengiriman',
    );
    notifyListeners();
    FirestoreDispatchService.instance.saveUserProfile(_currentUser!, uid: uid);
  }

  void register({
    required String name,
    required String email,
    required String password,
    required String storeLocation,
    int roleIndex = 0,
    double? latitude,
    double? longitude,
    String? uid,
  }) {
    final isDispatch = roleIndex == 0;
    final resolvedName = name.isNotEmpty
        ? name
        : (email.isNotEmpty ? _formatNameFromEmail(email) : 'Pengguna');
    final resolvedStore = storeLocation.isNotEmpty
        ? storeLocation
        : 'Dermaga Maccini Baji';

    // Auto-resolve known port/island coordinates or fallback
    final defaultCoord = LocationCoordinate.resolve(resolvedStore);
    final resolvedLat = latitude ?? defaultCoord.latitude;
    final resolvedLng = longitude ?? defaultCoord.longitude;

    _currentUser = UserProfile(
      name: resolvedName,
      organization: resolvedName,
      location: 'Kabupaten Pangkep',
      email: email,
      storeLocation: resolvedStore,
      latitude: resolvedLat,
      longitude: resolvedLng,
      accessRoleLabel:
          isDispatch ? 'Akses Pengirim ikan' : 'Akses Penerima ikan',
      permissionsDescription: isDispatch
          ? 'Membuat dan melihat pengiriman'
          : 'Menerima dan memeriksa pengiriman',
    );
    notifyListeners();
    FirestoreDispatchService.instance.saveUserProfile(_currentUser!, uid: uid);
  }

  /// Updates distributor location and geographical coordinates dynamically
  void updateDistributorLocation({
    required String storeLocation,
    required double latitude,
    required double longitude,
  }) {
    if (_currentUser == null) return;
    _currentUser = UserProfile(
      name: _currentUser!.name,
      organization: _currentUser!.organization,
      location: _currentUser!.location,
      email: _currentUser!.email,
      storeLocation: storeLocation,
      latitude: latitude,
      longitude: longitude,
      accessRoleLabel: _currentUser!.accessRoleLabel,
      permissionsDescription: _currentUser!.permissionsDescription,
      syncStatusDescription: _currentUser!.syncStatusDescription,
      isOnline: _currentUser!.isOnline,
    );
    notifyListeners();
    FirestoreDispatchService.instance.saveUserProfile(_currentUser!);
  }

  /// Updates distributor profile details and persists to Realtime Database
  Future<void> updateProfile({
    String? name,
    String? organization,
    String? storeLocation,
    String? location,
    String? phoneNumber,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentUser == null) return;
    final newStore = storeLocation ?? _currentUser!.storeLocation;
    final coord = (latitude != null && longitude != null)
        ? LocationCoordinate(name: newStore, latitude: latitude, longitude: longitude)
        : LocationCoordinate.resolve(newStore);

    _currentUser = UserProfile(
      name: name ?? _currentUser!.name,
      organization: organization ?? _currentUser!.organization,
      location: location ?? _currentUser!.location,
      email: _currentUser!.email,
      storeLocation: newStore,
      latitude: coord.latitude,
      longitude: coord.longitude,
      accessRoleLabel: _currentUser!.accessRoleLabel,
      permissionsDescription: _currentUser!.permissionsDescription,
      syncStatusDescription: _currentUser!.syncStatusDescription,
      isOnline: _currentUser!.isOnline,
      phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
    );
    notifyListeners();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirestoreDispatchService.instance.saveUserProfile(_currentUser!, uid: uid);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut notice: $e');
    }
    _currentUser = null;
    notifyListeners();
  }

  static Distributor? _matchDistributorByEmail(String email) {
    final lower = email.trim().toLowerCase();
    for (final d in FirestoreMasterDataService.defaultDistributors) {
      if (d.email.toLowerCase() == lower) return d;
      final prefix = d.email.split('@').first.toLowerCase();
      if (lower.startsWith(prefix)) return d;
    }
    return null;
  }

  static String _formatNameFromEmail(String email) {
    if (email.isEmpty) return 'Pengguna';
    final prefix = email.split('@').first;
    return prefix
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .where((s) => s.isNotEmpty)
        .join(' ');
  }
}
