import 'dart:async';
import 'dart:math' as math;

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
    return key.trim().replaceAll(RegExp(r'[.#$\[\]/\s]+'), '_');
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

      // 5. Seed Suhu Telemetry (Latest & History) if empty
      final suhuSnap = await _db.ref('suhu/SFR-CB-002/history').get();
      if (!suhuSnap.exists || suhuSnap.value == null) {
        await seedSuhuTelemetry(coolboxId: 'SFR-CB-002');
      }
    } catch (e) {
      debugPrint('RealtimeDB seedMasterData notice (offline or skipped): $e');
    }
  }

  // ============================================================================
  // SUHU TELEMETRY SEEDER & SIMULATOR (LATEST & HISTORY)
  // ============================================================================

  static String _formatHistoryKey(int counter) {
    final hex = counter.toRadixString(16).padLeft(16, '0');
    return 'r$hex';
  }

  Future<int> _getNextCounter(String coolboxId) async {
    try {
      final metaSnap = await _db
          .ref('suhu/$coolboxId/sync_meta/latest_id')
          .get();
      if (metaSnap.exists && metaSnap.value is String) {
        final idStr = metaSnap.value as String;
        final match = RegExp(r'^r([0-9a-fA-F]+)$').firstMatch(idStr);
        if (match != null) {
          final hex = match.group(1)!;
          return int.parse(hex, radix: 16) + 1;
        }
      }

      final histSnap = await _db.ref('suhu/$coolboxId/history').get();
      if (histSnap.exists && histSnap.value is Map) {
        final keys = (histSnap.value as Map).keys
            .map((k) => k.toString())
            .toList();
        if (keys.isNotEmpty) {
          keys.sort();
          final lastKey = keys.last;
          final match = RegExp(r'^r([0-9a-fA-F]+)$').firstMatch(lastKey);
          if (match != null) {
            final hex = match.group(1)!;
            return int.parse(hex, radix: 16) + 1;
          }
        }
      }
    } catch (_) {}
    return 0x1b1;
  }

  /// Seeds initial IoT temperature telemetry (`latest`, `history`, `sync_meta`)
  /// for [coolboxId] (default: 'SFR-CB-002') into Realtime Database.
  Future<void> seedSuhuTelemetry({
    String coolboxId = 'SFR-CB-002',
    bool isColdAndSafe = true,
    int initialHistoryCount = 10,
    bool forceClearHistory = false,
  }) async {
    try {
      if (forceClearHistory) {
        await _db.ref('suhu/$coolboxId/history').remove();
      }

      int counter = await _getNextCounter(coolboxId);
      final now = DateTime.now().toUtc();
      const interval = Duration(minutes: 5);
      final startTime = now.subtract(interval * (initialHistoryCount - 1));

      final Map<String, dynamic> updates = {};
      Map<String, dynamic>? lastSample;
      String? lastKey;

      final rand = math.Random();

      // Rute Maritim Pangkep (Pulau Balang Lompo -> Pelabuhan Maccini Baji)
      const originLat = -4.9350;
      const originLng = 119.3620;
      const destLat = -4.8378;
      const destLng = 119.5372;

      for (int i = 0; i < initialHistoryCount; i++) {
        final key = _formatHistoryKey(counter++);
        final timestamp = startTime.add(interval * i).toIso8601String();
        final progress = (i / math.max(1, initialHistoryCount - 1)).clamp(
          0.0,
          1.0,
        );

        final lat =
            originLat +
            (destLat - originLat) * progress +
            (rand.nextDouble() - 0.5) * 0.001;
        final lng =
            originLng +
            (destLng - originLng) * progress +
            (rand.nextDouble() - 0.5) * 0.001;

        double airTemp;
        double waterTemp;
        int humidity;
        int airQuality;

        if (isColdAndSafe) {
          // Cold chain aman: 1.2°C s/d 2.8°C
          airTemp = double.parse(
            (1.2 + rand.nextDouble() * 1.6).toStringAsFixed(1),
          );
          waterTemp = double.parse(
            (-0.5 + rand.nextDouble() * 0.5).toStringAsFixed(2),
          );
          humidity = 60 + rand.nextInt(15);
          airQuality = 40 + rand.nextInt(35);
        } else {
          // Anomali: di atas 4°C
          airTemp = double.parse(
            (8.5 + rand.nextDouble() * 6.0).toStringAsFixed(1),
          );
          waterTemp = double.parse(
            (3.5 + rand.nextDouble() * 4.0).toStringAsFixed(2),
          );
          humidity = 70 + rand.nextInt(25);
          airQuality = 150 + rand.nextInt(150);
        }

        final avgTemp = double.parse(
          ((airTemp + waterTemp) / 2).toStringAsFixed(2),
        );

        final sample = <String, dynamic>{
          'air_quality_value': airQuality,
          'air_temperature_c': airTemp,
          'average_temperature_c': avgTemp,
          'humidity_pct': humidity,
          'latitude': double.parse(lat.toStringAsFixed(6)),
          'longitude': double.parse(lng.toStringAsFixed(6)),
          'timestamp': timestamp,
          'water_temperature_c': waterTemp,
          'frostscore': isColdAndSafe ? 96.5 : 34.98,
        };

        updates['suhu/$coolboxId/history/$key'] = sample;
        lastSample = sample;
        lastKey = key;
      }

      if (lastSample != null && lastKey != null) {
        updates['suhu/$coolboxId/latest'] = lastSample;
        updates['suhu/$coolboxId/sync_meta/latest_id'] = lastKey;
      }

      await _db.ref().update(updates);
      debugPrint(
        'RealtimeDB: Seeded $initialHistoryCount telemetry points for $coolboxId (latest: $lastKey)',
      );
    } catch (e) {
      debugPrint('RealtimeDB seedSuhuTelemetry notice: $e');
    }
  }

  /// Simulates a single live tick of coolbox telemetry in Realtime Database.
  /// Updates `latest`, appends to `history/<key>`, and advances `sync_meta/latest_id`.
  Future<void> simulateSuhuTelemetryTick({
    String coolboxId = 'SFR-CB-002',
    double? airTemperature,
    double? waterTemperature,
    int? humidity,
    int? airQuality,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final counter = await _getNextCounter(coolboxId);
      final key = _formatHistoryKey(counter);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final rand = math.Random();

      final airTemp =
          airTemperature ??
          double.parse((1.5 + rand.nextDouble() * 1.5).toStringAsFixed(1));
      final waterTemp =
          waterTemperature ??
          double.parse((-0.3 + rand.nextDouble() * 0.4).toStringAsFixed(2));
      final avgTemp = double.parse(
        ((airTemp + waterTemp) / 2).toStringAsFixed(2),
      );
      final hum = humidity ?? (60 + rand.nextInt(15));
      final aq = airQuality ?? (50 + rand.nextInt(30));
      final lat = latitude ?? -4.8378;
      final lng = longitude ?? 119.5372;

      final sample = <String, dynamic>{
        'air_quality_value': aq,
        'air_temperature_c': airTemp,
        'average_temperature_c': avgTemp,
        'humidity_pct': hum,
        'latitude': double.parse(lat.toStringAsFixed(6)),
        'longitude': double.parse(lng.toStringAsFixed(6)),
        'timestamp': nowIso,
        'water_temperature_c': waterTemp,
        'frostscore': (airTemp <= 4.0) ? 96.5 : 34.98,
      };

      final updates = <String, dynamic>{
        'suhu/$coolboxId/history/$key': sample,
        'suhu/$coolboxId/latest': sample,
        'suhu/$coolboxId/sync_meta/latest_id': key,
      };

      await _db.ref().update(updates);
      debugPrint('RealtimeDB simulation tick: $coolboxId -> $key ($airTemp°C)');
    } catch (e) {
      debugPrint('RealtimeDB simulateSuhuTelemetryTick notice: $e');
    }
  }

  Timer? _simulationTimer;
  bool get isSimulationRunning => _simulationTimer?.isActive ?? false;

  /// Starts periodic simulation of coolbox temperature telemetry.
  void startLiveSuhuSimulation({
    String coolboxId = 'SFR-CB-002',
    Duration interval = const Duration(seconds: 3),
    bool isColdAndSafe = true,
  }) {
    stopLiveSuhuSimulation();
    debugPrint(
      'RealtimeDB: Starting live suhu simulation for $coolboxId every ${interval.inSeconds}s',
    );
    _simulationTimer = Timer.periodic(interval, (_) {
      simulateSuhuTelemetryTick(coolboxId: coolboxId);
    });
  }

  /// Stops the active periodic simulation timer.
  void stopLiveSuhuSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
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

        // 1. Simpan ke node 'users' di Realtime Database dengan key EMAIL (human-readable)
        try {
          final cleanEmailKey = _sanitizeKey(distributor.email);
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
          if (uid != null && uid.isNotEmpty) {
            userMap['uid'] = uid;
          }

          await _db.ref('users/$cleanEmailKey').update(userMap);
        } catch (e) {
          debugPrint('RealtimeDB users seed notice: $e');
        }

        // 2. Simpan ke node 'distributors' di Realtime Database dengan key NAMA DERMAGA/PULAU
        try {
          final distLocation = distributor.storeLocation.isNotEmpty
              ? distributor.storeLocation
              : distributor.name;
          final distKey = _sanitizeKey(distLocation);
          final distData = distributor.toMap();
          if (uid != null && uid.isNotEmpty) {
            distData['uid'] = uid;
          }
          distData['updatedAt'] = ServerValue.timestamp;

          await _db.ref('distributors/$distKey').update(distData);

          // Bersihkan entri duplikat lama dengan key UUID jika ada
          if (uid != null && uid.isNotEmpty) {
            if (uid != cleanEmailKey) {
              try {
                final oldUserSnap = await _db.ref('users/$uid').get();
                if (oldUserSnap.exists) await _db.ref('users/$uid').remove();
              } catch (_) {}
            }
            if (uid != distKey) {
              try {
                final oldDistSnap = await _db.ref('distributors/$uid').get();
                if (oldDistSnap.exists) await _db.ref('distributors/$uid').remove();
              } catch (_) {}
            }
          }
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

  /// Adds a new fish type to Realtime Database master_fishes
  Future<String> addFishType(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    try {
      final safeKey = _sanitizeKey(trimmed);
      await _db.ref('master_fishes/$safeKey').set({
        'name': trimmed,
        'createdAt': ServerValue.timestamp,
      });
      debugPrint('RealtimeDB: Added new fish type "$trimmed".');
    } catch (e) {
      debugPrint('Failed to add fish type to RealtimeDB: $e');
    }
    return trimmed;
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
