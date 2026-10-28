import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../firebase_options.dart';
import '../../domain/models/location_coordinate.dart';

/// Bundle of all master data for the dispatch form
class MasterFormData {
  const MasterFormData({
    required this.fishes,
    required this.weights,
    required this.distributors,
  });

  final List<String> fishes;
  final List<String> weights;
  final List<Distributor> distributors;
}

/// Representation of a distributor (from 'distributors' node in Realtime Database)
class Distributor {
  const Distributor({
    required this.name,
    required this.storeLocation,
    this.organization = '',
    this.email = '',
    this.role = 'distributor',
    this.latitude = -4.8378,
    this.longitude = 119.5372,
    this.password = 'smartfrost123',
  });

  final String name;
  final String storeLocation;
  final String organization;
  final String email;
  final String role;
  final double latitude;
  final double longitude;
  final String password;

  String get displayName =>
      storeLocation.isNotEmpty ? '$name ($storeLocation)' : name;

  factory Distributor.fromMap(Map<String, dynamic> map) {
    final store =
        map['storeLocation'] as String? ??
        map['location'] as String? ??
        'Dermaga Maccini Baji';
    final coord = LocationCoordinate.resolve(store);

    return Distributor(
      name: map['name'] as String? ?? 'Distributor',
      storeLocation: store,
      organization: map['organization'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'distributor',
      latitude: (map['latitude'] as num?)?.toDouble() ?? coord.latitude,
      longitude: (map['longitude'] as num?)?.toDouble() ?? coord.longitude,
      password: map['password'] as String? ?? 'smartfrost123',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storeLocation': storeLocation,
      'organization': organization,
      'email': email,
      'role': role,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Alias for backwards compatibility
typedef RealtimeMasterDataService = FirestoreMasterDataService;

/// Centralized service managing Master Data in Firebase Realtime Database:
/// - Coolbox IDs (`master_coolboxes`)
/// - Fish Types (`master_fishes`)
/// - Weight Ranges (`master_weights`)
/// - Destination Distributors (`distributors`)
class FirestoreMasterDataService {
  FirestoreMasterDataService._();
  static final FirestoreMasterDataService instance =
      FirestoreMasterDataService._();

  FirebaseDatabase? _rtdbInstance;
  FirebaseDatabase get _db {
    if (_rtdbInstance != null) return _rtdbInstance!;
    try {
      final defaultUrl = DefaultFirebaseOptions.currentPlatform.databaseURL;
      if (defaultUrl != null &&
          defaultUrl.isNotEmpty &&
          Firebase.apps.isNotEmpty) {
        _rtdbInstance = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: defaultUrl,
        );
      } else {
        _rtdbInstance = FirebaseDatabase.instance;
      }
    } catch (_) {
      _rtdbInstance = FirebaseDatabase.instance;
    }
    return _rtdbInstance!;
  }

  static String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
  }

  static Map<String, dynamic> _toMap(dynamic val) {
    if (val is Map) {
      return val.map(
        (k, v) => MapEntry(k.toString(), v is Map ? _toMap(v) : v),
      );
    }
    return <String, dynamic>{};
  }

  static const List<String> defaultCoolboxes = [
    'SFR-CB-042',
    'SFR-CB-108',
    'SFR-CB-201',
    'SFR-CB-315',
    'SFR-CB-101',
    'SFR-CB-001',
    'SFR-CB-002',
    'SFR-CB-003',
    'SFR-CB-004',
    'SFR-CB-005',
  ];

  static const List<String> defaultFishes = [
    'Ikan Bandeng',
    'Ikan Tongkol',
    'Ikan Kerapu',
    'Ikan Cakalang',
    'Ikan Kakap Merah',
    'Ikan Tenggiri',
  ];

  static const List<String> defaultWeights = [
    '50 - 60 kg',
    '70 - 80 kg',
    '80 - 90 kg',
    '90 - 100 kg',
    '100 - 120 kg',
  ];

  static const List<Distributor> defaultDistributors = [
    Distributor(
      name: 'Dermaga Maccini Baji',
      storeLocation: 'Dermaga Maccini Baji',
      organization: 'Distributor Dermaga Maccini Baji',
      email: 'maccinibaji@smartfrost.id',
      role: 'distributor',
      latitude: -4.774082446457824,
      longitude: 119.4936169873191,
    ),
    Distributor(
      name: 'Dermaga Biringkassi',
      storeLocation: 'Dermaga Biringkassi',
      organization: 'Distributor Dermaga Biringkassi',
      email: 'biringkassi@smartfrost.id',
      role: 'distributor',
      latitude: -4.7958,
      longitude: 119.5085,
    ),
    Distributor(
      name: 'Pulau Karanrang',
      storeLocation: 'Pulau Karanrang',
      organization: 'Distributor Pulau Karanrang',
      email: 'karanrang@smartfrost.id',
      role: 'distributor',
      latitude: -4.8631,
      longitude: 119.3872,
    ),
    Distributor(
      name: 'Pulau Sanane',
      storeLocation: 'Pulau Sanane',
      organization: 'Distributor Pulau Sanane',
      email: 'sanane@smartfrost.id',
      role: 'distributor',
      latitude: -4.8986,
      longitude: 119.3361,
    ),
    Distributor(
      name: 'Pulau Jangan-Jangangan',
      storeLocation: 'Pulau Jangan-Jangangan',
      organization: 'Distributor Pulau Jangan-Jangangan',
      email: 'jangangan@smartfrost.id',
      role: 'distributor',
      latitude: -4.8620,
      longitude: 119.3510,
    ),
    Distributor(
      name: 'Pulau Kalupu',
      storeLocation: 'Pulau Kalupu',
      organization: 'Distributor Pulau Kalupu',
      email: 'kalupu@smartfrost.id',
      role: 'distributor',
      latitude: -4.8450,
      longitude: 119.3100,
    ),
    Distributor(
      name: 'Pulau Kapoposang',
      storeLocation: 'Pulau Kapoposang',
      organization: 'Distributor Pulau Kapoposang',
      email: 'kapoposang@smartfrost.id',
      role: 'distributor',
      latitude: -4.6958,
      longitude: 118.9536,
    ),
  ];

  /// Populates master data nodes in Realtime Database if they are empty
  Future<void> seedMasterDataIfNeeded() async {
    try {
      // 1. Seed Coolboxes
      final coolboxSnap = await _db.ref('master_coolboxes').get();
      if (!coolboxSnap.exists || coolboxSnap.value == null) {
        final Map<String, dynamic> updates = {};
        for (final cb in defaultCoolboxes) {
          final safeKey = _sanitizeKey(cb);
          updates['master_coolboxes/$safeKey'] = {
            'code': cb,
            'capacity': '120 kg',
            'status': 'Tersedia',
            'createdAt': ServerValue.timestamp,
          };
        }
        await _db.ref().update(updates);
        debugPrint('RealtimeDB: Master coolboxes seeded.');
      }

      // 2. Seed Fish Types
      final fishSnap = await _db.ref('master_fishes').get();
      if (!fishSnap.exists || fishSnap.value == null) {
        final Map<String, dynamic> updates = {};
        for (final fish in defaultFishes) {
          final safeKey = _sanitizeKey(fish);
          updates['master_fishes/$safeKey'] = {
            'name': fish,
            'createdAt': ServerValue.timestamp,
          };
        }
        await _db.ref().update(updates);
        debugPrint('RealtimeDB: Master fishes seeded.');
      }

      // 3. Seed Weights
      final weightSnap = await _db.ref('master_weights').get();
      if (!weightSnap.exists || weightSnap.value == null) {
        final Map<String, dynamic> updates = {};
        for (int i = 0; i < defaultWeights.length; i++) {
          final w = defaultWeights[i];
          updates['master_weights/w_$i'] = {
            'range': w,
            'order': i,
            'createdAt': ServerValue.timestamp,
          };
        }
        await _db.ref().update(updates);
        debugPrint('RealtimeDB: Master weights seeded.');
      }

      // 4. Seed Destination Distributors & Auth Accounts
      final distSnap = await _db.ref('distributors').get();
      if (!distSnap.exists || distSnap.value == null) {
        await seedDistributorAccounts();
      }
    } catch (e) {
      debugPrint('RealtimeDB seedMasterData notice (offline or skipped): $e');
    }
  }

  /// Seeds distributor user accounts into Firebase Authentication and Realtime Database
  Future<void> seedDistributorAccounts({
    String defaultPassword = 'smartfrost123',
  }) async {
    FirebaseApp? seederApp;
    FirebaseAuth seederAuth;
    try {
      try {
        final existingSeeder = Firebase.apps
            .where((a) => a.name == 'DistributorSeederApp')
            .firstOrNull;
        if (existingSeeder != null) {
          seederApp = existingSeeder;
        } else {
          seederApp = await Firebase.initializeApp(
            name: 'DistributorSeederApp',
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        seederAuth = FirebaseAuth.instanceFor(app: seederApp);
      } catch (e) {
        debugPrint('Notice on secondary FirebaseApp init: $e');
        seederAuth = FirebaseAuth.instance;
      }

      for (final distributor in defaultDistributors) {
        String? uid;
        final cleanEmailKey = distributor.email.replaceAll('.', '_');

        // Cek apakah node user sudah ada di RTDB untuk menghindari throw Exception saat debug
        final existingUserSnap = await _db.ref('users/$cleanEmailKey').get();
        final bool userAlreadyExists =
            existingUserSnap.exists && existingUserSnap.value != null;

        if (!userAlreadyExists) {
          try {
            final cred = await seederAuth.createUserWithEmailAndPassword(
              email: distributor.email,
              password: defaultPassword,
            );
            await cred.user?.updateDisplayName(distributor.name);
            uid = cred.user?.uid;
            debugPrint(
              'Firebase Auth: Akun ${distributor.email} berhasil dibuat (UID: $uid)',
            );
          } on FirebaseAuthException catch (authEx) {
            if (authEx.code == 'email-already-in-use' ||
                authEx.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              debugPrint(
                'Firebase Auth: Akun ${distributor.email} sudah terdaftar.',
              );
            } else {
              debugPrint(
                'Firebase Auth seed notice for ${distributor.email}: ${authEx.message}',
              );
            }
          } on PlatformException catch (platEx) {
            if (platEx.code == 'ERROR_EMAIL_ALREADY_IN_USE' ||
                platEx.code == 'email-already-in-use') {
              debugPrint(
                'Firebase Auth: Akun ${distributor.email} sudah terdaftar.',
              );
            } else {
              debugPrint(
                'PlatformException seed notice for ${distributor.email}: ${platEx.message}',
              );
            }
          } catch (e) {
            debugPrint('Auth seeding fallback for ${distributor.email}: $e');
          }
        }

        // 1. Simpan ke node 'users' di Realtime Database
        try {
          final cleanEmailKey = distributor.email.replaceAll('.', '_');
          final userMap = <String, dynamic>{
            'name': distributor.name,
            'organization': distributor.organization,
            'email': distributor.email,
            'storeLocation': distributor.storeLocation,
            'location': 'Kabupaten Pangkep',
            'latitude': distributor.latitude,
            'longitude': distributor.longitude,
            'role': distributor.role,
            'accessRoleLabel': 'Akses Mitra Distributor',
            'permissionsDescription': 'Menerima dan mengirim ikan',
            'updatedAt': ServerValue.timestamp,
          };
          if (uid != null) {
            userMap['uid'] = uid;
          }

          await _db.ref('users/$cleanEmailKey').update(userMap);
        } catch (e) {
          debugPrint('RealtimeDB users seed notice: $e');
        }

        // 2. Simpan ke node 'distributors' di Realtime Database
        try {
          final distDocId = _sanitizeKey(distributor.name);
          final distData = distributor.toMap();
          if (uid != null) distData['uid'] = uid;
          distData['updatedAt'] = ServerValue.timestamp;

          await _db.ref('distributors/$distDocId').update(distData);
        } catch (e) {
          debugPrint('RealtimeDB distributors seed notice: $e');
        }
      }
      debugPrint('RealtimeDB: Seeding distributor accounts completed.');
    } catch (e) {
      debugPrint('Error in seedDistributorAccounts: $e');
    } finally {
      if (seederApp != null) {
        try {
          await seederApp.delete();
        } catch (_) {}
      }
    }
  }

  /// Realtime stream of coolbox IDs from RTDB
  Stream<List<String>> streamCoolboxes() {
    try {
      return _db.ref('master_coolboxes').onValue.map((event) {
        final snap = event.snapshot;
        if (!snap.exists || snap.value == null) return defaultCoolboxes;
        final val = snap.value;
        if (val is Map) {
          final list = <String>[];
          for (final entry in val.entries) {
            final data = entry.value;
            if (data is Map) {
              final code = data['code']?.toString() ?? entry.key.toString();
              list.add(code);
            } else if (data is String) {
              list.add(data);
            } else {
              list.add(entry.key.toString());
            }
          }
          return list.isNotEmpty ? list : defaultCoolboxes;
        } else if (val is List) {
          final list = val
              .where((e) => e != null)
              .map(
                (e) => e is Map ? (e['code']?.toString() ?? '') : e.toString(),
              )
              .where((s) => s.isNotEmpty)
              .toList();
          return list.isNotEmpty ? list : defaultCoolboxes;
        }
        return defaultCoolboxes;
      });
    } catch (_) {
      return Stream.value(defaultCoolboxes);
    }
  }

  /// Realtime stream of fish types from RTDB
  Stream<List<String>> streamFishes() {
    try {
      return _db.ref('master_fishes').onValue.map((event) {
        final snap = event.snapshot;
        if (!snap.exists || snap.value == null) return defaultFishes;
        final val = snap.value;
        if (val is Map) {
          final list = <String>[];
          for (final entry in val.entries) {
            final data = entry.value;
            if (data is Map) {
              final name = data['name']?.toString() ?? entry.key.toString();
              list.add(name);
            } else if (data is String) {
              list.add(data);
            } else {
              list.add(entry.key.toString());
            }
          }
          return list.isNotEmpty ? list : defaultFishes;
        } else if (val is List) {
          final list = val
              .where((e) => e != null)
              .map(
                (e) => e is Map ? (e['name']?.toString() ?? '') : e.toString(),
              )
              .where((s) => s.isNotEmpty)
              .toList();
          return list.isNotEmpty ? list : defaultFishes;
        }
        return defaultFishes;
      });
    } catch (_) {
      return Stream.value(defaultFishes);
    }
  }

  /// Realtime stream of weight options from RTDB
  Stream<List<String>> streamWeights() {
    try {
      return _db.ref('master_weights').orderByChild('order').onValue.map((
        event,
      ) {
        final snap = event.snapshot;
        if (!snap.exists || snap.value == null) return defaultWeights;
        final val = snap.value;
        if (val is Map) {
          final entries = val.entries.toList();
          entries.sort((a, b) {
            final orderA = (a.value is Map)
                ? (a.value['order'] as num? ?? 0)
                : 0;
            final orderB = (b.value is Map)
                ? (b.value['order'] as num? ?? 0)
                : 0;
            return orderA.compareTo(orderB);
          });
          final list = entries
              .map(
                (e) => (e.value is Map)
                    ? (e.value['range']?.toString() ?? '')
                    : '',
              )
              .where((w) => w.isNotEmpty)
              .toList();
          return list.isNotEmpty ? list : defaultWeights;
        } else if (val is List) {
          final list = val
              .where((e) => e != null)
              .map(
                (e) => e is Map ? (e['range']?.toString() ?? '') : e.toString(),
              )
              .where((s) => s.isNotEmpty)
              .toList();
          return list.isNotEmpty ? list : defaultWeights;
        }
        return defaultWeights;
      });
    } catch (_) {
      return Stream.value(defaultWeights);
    }
  }

  /// Realtime stream of destination distributors from RTDB
  Stream<List<Distributor>> streamDistributors() {
    try {
      return _db.ref('distributors').onValue.map((event) {
        final snap = event.snapshot;
        if (!snap.exists || snap.value == null) return defaultDistributors;
        final val = snap.value;
        if (val is Map) {
          final list = <Distributor>[];
          final seenKeys = <String>{};
          for (final entry in val.entries) {
            if (entry.value is Map) {
              final map = _toMap(entry.value);
              final dist = Distributor.fromMap(map);
              if (seenKeys.add(dist.displayName)) {
                list.add(dist);
              }
            }
          }
          return list.isNotEmpty ? list : defaultDistributors;
        } else if (val is List) {
          final list = <Distributor>[];
          final seenKeys = <String>{};
          for (final e in val.whereType<Map>()) {
            final dist = Distributor.fromMap(_toMap(e));
            if (seenKeys.add(dist.displayName)) {
              list.add(dist);
            }
          }
          return list.isNotEmpty ? list : defaultDistributors;
        }
        return defaultDistributors;
      });
    } catch (_) {
      return Stream.value(defaultDistributors);
    }
  }

  /// Combined reactive stream of all cargo master data
  Stream<MasterFormData> streamFormData() {
    final controller = StreamController<MasterFormData>.broadcast();
    var currentFishes = defaultFishes;
    var currentWeights = defaultWeights;
    var currentDistributors = defaultDistributors;

    void emit() {
      if (!controller.isClosed) {
        controller.add(
          MasterFormData(
            fishes: currentFishes,
            weights: currentWeights,
            distributors: currentDistributors,
          ),
        );
      }
    }

    final sub1 = streamFishes().listen((data) {
      currentFishes = data;
      emit();
    }, onError: (_) {});

    final sub2 = streamWeights().listen((data) {
      currentWeights = data;
      emit();
    }, onError: (_) {});

    final sub3 = streamDistributors().listen((data) {
      currentDistributors = data;
      emit();
    }, onError: (_) {});

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
      sub3.cancel();
    };

    return controller.stream;
  }
}
