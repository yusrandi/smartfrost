import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../../firebase_options.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../domain/models/dispatch_item.dart';
import '../../domain/models/location_coordinate.dart';
import '../../domain/models/new_dispatch_data.dart';
import '../../../history/domain/models/history_batch_item.dart';
import '../../../history/domain/models/history_filter.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../receiving/domain/models/fish_batch_item.dart';
import 'firestore_master_data_service.dart';

/// Real-time Firebase Realtime Database service connecting Mobile app and Web dashboard,
/// synchronizing active fish dispatches, vessel GPS coordinates, and distributor store metadata.
class RealtimeDispatchService {
  RealtimeDispatchService._();
  static final RealtimeDispatchService instance = RealtimeDispatchService._();

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

  /// Helper to convert dynamic RTDB Map to `Map<String, dynamic>`
  Map<String, dynamic> _toMap(dynamic val) {
    if (val is Map) {
      return val.map(
        (k, v) => MapEntry(k.toString(), v is Map ? _toMap(v) : v),
      );
    }
    return <String, dynamic>{};
  }

  /// Helper to parse timestamp from RTDB (epoch int, ISO string, or DateTime)
  DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String) return DateTime.tryParse(val);
    if (val is DateTime) return val;
    try {
      return (val as dynamic).toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }

  /// Saves a newly created dispatch batch into Realtime Database `/dispatches` node,
  /// updates coolbox status in `/master_coolboxes`, and logs the initial route waypoint.
  Future<void> saveDispatch(NewDispatchData data) async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint(
          'Realtime Database saveDispatch notice: Firebase not initialized.',
        );
        return;
      }

      final originCoord = LocationCoordinate.resolve(data.originLocation);
      final destCoord = LocationCoordinate.resolve(data.destinationLocation);

      final batchId = data.batchId.isNotEmpty
          ? data.batchId
          : NewDispatchData.generateBatchId(coolboxId: data.coolboxId);

      final currentUser = AuthSession.instance.currentUser;
      final senderEmail = currentUser?.email ?? 'bahari@smartfrost.id';
      String? senderUid;
      try {
        senderUid = FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {}

      // Base Distributor ID (pengirim)
      String distributorId = 'distributor-default';
      if (senderUid != null && senderUid.isNotEmpty) {
        distributorId = senderUid;
      } else if (currentUser != null) {
        distributorId = currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : currentUser.name.toLowerCase().replaceAll(
                RegExp(r'[^a-z0-9]'),
                '_',
              );
      }

      // Resolve receiver distributor details
      String receiverDistributorId = '';
      String receiverEmail = '';
      final matchedDist = FirestoreMasterDataService.defaultDistributors
          .where(
            (d) =>
                d.name == data.receiverName ||
                d.storeLocation == data.destinationLocation,
          )
          .firstOrNull;
      if (matchedDist != null) {
        receiverEmail = matchedDist.email;
        receiverDistributorId = matchedDist.email.split('@').first;
      }

      final coolboxList = data.coolboxIds.isNotEmpty
          ? data.coolboxIds
          : [data.coolboxId];

      final dispatchMap = <String, dynamic>{
        'batchId': batchId,
        'dispatchId': batchId,
        'distributorId': distributorId,
        'distributorName': data.senderName,
        'distributorEmail': senderEmail,
        'distributorLocation': data.originLocation,
        'senderName': data.senderName,
        'senderEmail': senderEmail,
        'coolboxId': data.coolboxId,
        'coolboxIds': coolboxList,
        'fishType': data.fishType,
        'weightRange': data.weightRange,
        'originLocation': data.originLocation,
        'originLatitude': originCoord.latitude,
        'originLongitude': originCoord.longitude,
        'destinationLocation': data.destinationLocation,
        'destinationLatitude': destCoord.latitude,
        'destinationLongitude': destCoord.longitude,
        'currentLatitude': originCoord.latitude,
        'currentLongitude': originCoord.longitude,
        'receiverDistributorId': receiverDistributorId,
        'receiverName': data.receiverName,
        'receiverEmail': receiverEmail,
        'status': 'Dalam Perjalanan',
        'temperature': -2.4,
        'frostScore': 96,
        'dataStatus': data.dataStatus,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };
      if (senderUid != null && senderUid.isNotEmpty) {
        dispatchMap['senderUid'] = senderUid;
      }

      // 1. Save dispatch to Realtime Database `/dispatches/{batchId}`
      await _db.ref('dispatches/$batchId').update(dispatchMap);

      // 2. Update coolbox status to 'Digunakan' in `/master_coolboxes/{coolboxId}`
      try {
        await _db.ref('master_coolboxes/${data.coolboxId}').update({
          'code': data.coolboxId,
          'status': 'Digunakan',
          'currentBatchId': batchId,
          'destination': data.destinationLocation,
          'lastDispatchedAt': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint('Realtime Database update coolbox notice: $e');
      }

      // 3. Initial tracking waypoint in `/dispatches/{batchId}/tracking_logs/init`
      try {
        await _db.ref('dispatches/$batchId/tracking_logs/init').set({
          'batchId': batchId,
          'latitude': originCoord.latitude,
          'longitude': originCoord.longitude,
          'locationName': data.originLocation,
          'temperature': -2.4,
          'status': 'Pengiriman dimulai dari ${data.originLocation}',
          'timestamp': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint('Realtime Database initial tracking log notice: $e');
      }

      debugPrint(
        'Realtime Database: Dispatched batch $batchId saved successfully.',
      );
    } catch (e) {
      debugPrint(
        'Realtime Database saveDispatch notice (offline or uninitialized): $e',
      );
    }
  }

  /// Live-streams current vessel / mobile GPS telemetry into Realtime Database for web map tracking.
  Future<void> updateDispatchLocation({
    required String batchId,
    required double latitude,
    required double longitude,
    String? distanceRemaining,
    bool? isMocked,
    double? speed,
  }) async {
    try {
      if (Firebase.apps.isEmpty || batchId.trim().isEmpty) return;

      final updateData = <String, dynamic>{
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'updatedAt': ServerValue.timestamp,
      };
      if (distanceRemaining != null) {
        updateData['distanceRemaining'] = distanceRemaining;
      }
      if (isMocked != null) {
        updateData['isMockedLocation'] = isMocked;
      }
      if (speed != null) {
        updateData['speed'] = speed;
      }
      await _db.ref('dispatches/${batchId.trim()}').update(updateData);
    } catch (e) {
      debugPrint('Realtime Database updateDispatchLocation notice: $e');
    }
  }

  /// Confirms reception of a batch by the receiver distributor:
  /// - Updates status in `/dispatches` to 'Diterima'
  /// - Updates coolbox status in `/master_coolboxes` to 'Tersedia'
  /// - Appends a tracking waypoint indicating successful receiving.
  Future<bool> confirmReceivingBatch({
    required String batchId,
    String? coolboxId,
    String? receiverName,
    String? locationName,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return true;

      await _db.ref('dispatches/$batchId').update({
        'status': 'Diterima',
        'receivedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      // Update coolbox status to 'Tersedia'
      if (coolboxId != null && coolboxId.isNotEmpty) {
        try {
          await _db.ref('master_coolboxes/$coolboxId').update({
            'status': 'Tersedia',
            'currentBatchId': null,
            'updatedAt': ServerValue.timestamp,
          });
        } catch (e) {
          debugPrint('Realtime Database update coolbox status notice: $e');
        }
      }

      // Add tracking log waypoint for reception
      try {
        await _db.ref('dispatches/$batchId/tracking_logs').push().set({
          'batchId': batchId,
          'status':
              'Ikan diterima dengan baik oleh ${receiverName ?? "Penerima"}',
          'locationName': locationName ?? 'Lokasi Penerima',
          'temperature': -2.4,
          'timestamp': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint('Realtime Database tracking log notice: $e');
      }

      debugPrint('Realtime Database: Batch $batchId marked as Diterima.');
      return true;
    } catch (e) {
      debugPrint('Realtime Database confirmReceivingBatch error: $e');
      return false;
    }
  }

  /// Rejects reception of a batch by the receiver distributor:
  /// - Updates status in `/dispatches` to 'Ditolak'
  /// - Sets coolbox status back to 'Tersedia' in `/master_coolboxes`
  Future<bool> rejectReceivingBatch({
    required String batchId,
    String? coolboxId,
    String? receiverName,
    String? locationName,
    String? reason,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return true;

      await _db.ref('dispatches/$batchId').update({
        'status': 'Ditolak',
        'rejectedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
        'rejectionReason':
            reason ?? 'Kondisi fisik ikan tidak memenuhi standar penerimaan',
      });

      if (coolboxId != null && coolboxId.isNotEmpty) {
        try {
          await _db.ref('master_coolboxes/$coolboxId').update({
            'status': 'Tersedia',
            'currentBatchId': null,
            'updatedAt': ServerValue.timestamp,
          });
        } catch (_) {}
      }

      debugPrint('Realtime Database: Batch $batchId marked as Ditolak.');
      return true;
    } catch (e) {
      debugPrint('Realtime Database rejectReceivingBatch error: $e');
      return false;
    }
  }

  /// Finds an active or past dispatch record by coolbox ID or batch ID
  Future<Map<String, dynamic>?> findDispatchByCoolboxOrBatch(
    String code,
  ) async {
    try {
      if (Firebase.apps.isEmpty) return null;
      final cleanCode = code.trim();
      if (cleanCode.isEmpty) return null;

      // 1. Try direct node ID (batchId)
      final directSnap = await _db.ref('dispatches/$cleanCode').get();
      if (directSnap.exists && directSnap.value != null) {
        return _toMap(directSnap.value);
      }

      // 2. Query all dispatches and find matching coolboxId or batchId
      final allSnap = await _db.ref('dispatches').get();
      if (allSnap.exists && allSnap.value != null) {
        final allMap = _toMap(allSnap.value);
        final matches = <Map<String, dynamic>>[];

        for (final entry in allMap.entries) {
          final data = _toMap(entry.value);
          final bId = (data['batchId'] as String? ?? entry.key).trim();
          final cbId = (data['coolboxId'] as String? ?? '').trim();
          final cbList = data['coolboxIds'];

          bool isMatch = bId == cleanCode || cbId == cleanCode;
          if (!isMatch && cbList is List) {
            isMatch = cbList.any((c) => c.toString().trim() == cleanCode);
          }

          if (isMatch) {
            matches.add(data);
          }
        }

        if (matches.isNotEmpty) {
          matches.sort((a, b) {
            final aTime = a['createdAt'];
            final bTime = b['createdAt'];
            final aNum = aTime is num ? aTime : 0;
            final bNum = bTime is num ? bTime : 0;
            return bNum.compareTo(aNum);
          });
          return matches.first;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Realtime Database findDispatchByCoolboxOrBatch notice: $e');
      return null;
    }
  }

  /// Returns the list of coolbox IDs currently expected/incoming for the receiver.
  /// Only includes active/in-transit/pending dispatches addressed to this receiver.
  Future<List<String>> getIncomingCoolboxIds({UserProfile? user}) async {
    try {
      if (Firebase.apps.isEmpty) return [];

      final activeUser = user ?? AuthSession.instance.currentUser;
      final snapshot = await _db.ref('dispatches').get();
      final coolboxIds = <String>{};

      if (snapshot.exists && snapshot.value != null) {
        final allMap = _toMap(snapshot.value);
        for (final entry in allMap.entries) {
          final data = _toMap(entry.value);
          if (activeUser == null || _isReceiverMatch(data, activeUser)) {
            final status = (data['status'] as String? ?? '').toLowerCase();
            final isCompleted = status == 'diterima' || status == 'selesai';
            final coolboxId = (data['coolboxId'] as String? ?? '').trim();
            if (coolboxId.isNotEmpty && !isCompleted) {
              coolboxIds.add(coolboxId);
            }
          }
        }
      }

      final list = coolboxIds.toList()..sort();
      return list;
    } catch (e) {
      debugPrint('Realtime Database getIncomingCoolboxIds notice: $e');
      return [];
    }
  }

  /// Finds an inbound dispatch for the given coolbox ID or batch ID,
  /// strictly validated against the receiver's identity.
  Future<Map<String, dynamic>?> findReceivingDispatchByCoolboxOrBatch(
    String code, {
    UserProfile? user,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return null;

      final activeUser = user ?? AuthSession.instance.currentUser;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return null;

      final snapshot = await _db.ref('dispatches').get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final allMap = _toMap(snapshot.value);
      final matches = <Map<String, dynamic>>[];

      for (final entry in allMap.entries) {
        final data = _toMap(entry.value);
        final bId = (data['batchId'] as String? ?? entry.key).trim();
        final cbId = (data['coolboxId'] as String? ?? '').trim();

        if (bId == trimmed || cbId == trimmed) {
          if (activeUser == null || _isReceiverMatch(data, activeUser)) {
            matches.add(data);
          }
        }
      }

      if (matches.isEmpty) return null;

      // Sort newest first
      matches.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        final aNum = aTime is num ? aTime : 0;
        final bNum = bTime is num ? bTime : 0;
        return bNum.compareTo(aNum);
      });

      return matches.first;
    } catch (e) {
      debugPrint(
        'Realtime Database findReceivingDispatchByCoolboxOrBatch notice: $e',
      );
      return null;
    }
  }

  /// Stream of all dispatches ordered by creation time for listings.
  Stream<List<Map<String, dynamic>>> streamDispatches() {
    try {
      if (Firebase.apps.isEmpty) return const Stream.empty();
      return _db.ref('dispatches').onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];
        final map = _toMap(event.snapshot.value);
        final list = map.values.map((v) => _toMap(v)).toList();
        list.sort((a, b) {
          final aTime = a['createdAt'] is num ? a['createdAt'] as num : 0;
          final bTime = b['createdAt'] is num ? b['createdAt'] as num : 0;
          return bTime.compareTo(aTime);
        });
        return list;
      });
    } catch (e) {
      debugPrint('Realtime Database streamDispatches notice: $e');
      return const Stream.empty();
    }
  }

  /// Realtime stream converting RTDB `dispatches` into strongly typed `DispatchItem`s
  /// filtered specifically for the logged-in distributor as SENDER (outbound).
  Stream<List<DispatchItem>> streamDispatchItems({UserProfile? user}) {
    try {
      if (Firebase.apps.isEmpty) return const Stream.empty();
      final activeUser = user ?? AuthSession.instance.currentUser;
      return _db.ref('dispatches').onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];
        final allMap = _toMap(event.snapshot.value);

        final items = <DispatchItem>[];
        for (final entry in allMap.entries) {
          final data = _toMap(entry.value);
          if (activeUser != null && !_isSenderMatch(data, activeUser)) {
            continue;
          }

          final batchId = data['batchId'] as String? ?? entry.key;
          final fishType = data['fishType'] as String? ?? 'Ikan Campur';
          final weightRange = data['weightRange'] as String? ?? '85 kg';
          final weightMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(weightRange);
          final weightVal = weightMatch != null
              ? double.tryParse(weightMatch.group(1)!) ?? 85.0
              : 85.0;

          final origin =
              data['originLocation'] as String? ?? 'Dermaga Maccini Baji';
          final dest =
              data['destinationLocation'] as String? ??
              'Pulau Jangang-Jangangan';
          final status = data['status'] as String? ?? 'Dalam Perjalanan';

          String formattedDate = 'Hari ini';
          final dt = _parseDateTime(data['createdAt']);
          if (dt != null) {
            formattedDate =
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
          }

          items.add(
            DispatchItem(
              id: entry.key,
              batchCode: batchId,
              fishType: fishType,
              weightKg: weightVal,
              origin: origin,
              destination: dest,
              formattedDate: formattedDate,
              statusLabel: status,
              isSynchronized: true,
            ),
          );
        }

        // Sort descending
        items.sort((a, b) => b.batchCode.compareTo(a.batchCode));
        return items;
      });
    } catch (e) {
      debugPrint('Realtime Database streamDispatchItems notice: $e');
      return const Stream.empty();
    }
  }

  /// Realtime stream converting RTDB `dispatches` into inbound `FishBatchItem`s
  /// filtered specifically for the logged-in distributor as RECEIVER (inbound).
  Stream<List<FishBatchItem>> streamReceivingBatches({UserProfile? user}) {
    try {
      if (Firebase.apps.isEmpty) return const Stream.empty();
      final activeUser = user ?? AuthSession.instance.currentUser;
      return _db.ref('dispatches').onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];
        final allMap = _toMap(event.snapshot.value);

        final items = <FishBatchItem>[];
        for (final entry in allMap.entries) {
          final data = _toMap(entry.value);
          if (activeUser != null && !_isReceiverMatch(data, activeUser)) {
            continue;
          }

          final batchId = data['batchId'] as String? ?? entry.key;
          final fishType = data['fishType'] as String? ?? 'Ikan Campur';
          final weightRange = data['weightRange'] as String? ?? '85 kg';
          final weightMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(weightRange);
          final weightVal = weightMatch != null
              ? double.tryParse(weightMatch.group(1)!) ?? 85.0
              : 85.0;
          final senderName = data['senderName'] as String? ?? '-';
          final statusStr = data['status'] as String? ?? 'Dalam Perjalanan';

          BatchInspectionStatus status = BatchInspectionStatus.pending;
          final sLower = statusStr.toLowerCase();
          if (sLower.contains('tolak')) {
            status = BatchInspectionStatus.rejected;
          } else if (sLower.contains('selesai periksa')) {
            status = BatchInspectionStatus.inspected;
          } else if (sLower.contains('selesai') || sLower.contains('diterima')) {
            status = BatchInspectionStatus.received;
          } else {
            status = BatchInspectionStatus.pending;
          }

          String formattedDate = 'Hari ini';
          final dt = _parseDateTime(data['createdAt']);
          if (dt != null) {
            formattedDate =
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
          }

          final coolboxId = data['coolboxId'] as String? ?? '';
          items.add(
            FishBatchItem(
              id: entry.key,
              batchCode: batchId,
              coolboxId: coolboxId,
              fishType: fishType,
              weightKg: weightVal,
              supplierName: senderName,
              formattedDate: formattedDate,
              status: status,
              isSynchronized: true,
            ),
          );
        }

        items.sort((a, b) => b.batchCode.compareTo(a.batchCode));
        return items;
      });
    } catch (e) {
      debugPrint('Realtime Database streamReceivingBatches notice: $e');
      return const Stream.empty();
    }
  }

  /// Realtime stream converting RTDB `dispatches` into strongly typed `HistoryBatchItem`s
  /// filtered specifically by role.
  Stream<List<HistoryBatchItem>> streamHistoryItems({
    required bool isDispatch,
    UserProfile? user,
  }) {
    try {
      if (Firebase.apps.isEmpty) return const Stream.empty();
      final activeUser = user ?? AuthSession.instance.currentUser;
      return _db.ref('dispatches').onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];
        final allMap = _toMap(event.snapshot.value);

        final items = <HistoryBatchItem>[];
        for (final entry in allMap.entries) {
          final data = _toMap(entry.value);
          final isMatch = isDispatch
              ? (activeUser == null || _isSenderMatch(data, activeUser))
              : (activeUser == null || _isReceiverMatch(data, activeUser));

          if (!isMatch) continue;

          final batchId = data['batchId'] as String? ?? entry.key;
          final fishType = data['fishType'] as String? ?? 'Ikan Campur';
          final weightRange = data['weightRange'] as String? ?? '85 kg';
          final origin =
              data['originLocation'] as String? ?? 'Dermaga Maccini Baji';
          final dest =
              data['destinationLocation'] as String? ??
              'Pulau Jangang-Jangangan';
          final route = '$origin → $dest';
          final supplier =
              data['senderName'] as String? ??
              data['distributorName'] as String? ??
              '-';
          final statusStr = data['status'] as String? ?? 'Menunggu periksa';

          HistoryFilterStatus filterCat = HistoryFilterStatus.active;
          final statusLower = statusStr.toLowerCase();
          if (statusLower.contains('selesai') ||
              statusLower.contains('diterima') ||
              statusLower.contains('periksa')) {
            filterCat = HistoryFilterStatus.completed;
          } else if (statusLower.contains('tolak')) {
            filterCat = HistoryFilterStatus.rejected;
          }

          String formattedDate = 'Hari ini';
          final dt = _parseDateTime(data['createdAt']);
          if (dt != null) {
            final stdMonths = [
              '',
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'Mei',
              'Jun',
              'Jul',
              'Ags',
              'Sep',
              'Okt',
              'Nov',
              'Des',
            ];
            final monthStr = dt.month <= 12
                ? stdMonths[dt.month]
                : '${dt.month}';
            formattedDate =
                '${dt.day.toString().padLeft(2, '0')} $monthStr ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
          }

          items.add(
            HistoryBatchItem(
              id: entry.key,
              batchCode: batchId,
              fishType: fishType,
              weightLabel: weightRange,
              route: isDispatch ? route : null,
              supplier: !isDispatch ? supplier : null,
              date: formattedDate,
              statusLabel: statusStr,
              filterCategory: filterCat,
              isSynchronized: true,
            ),
          );
        }

        items.sort((a, b) => b.batchCode.compareTo(a.batchCode));
        return items;
      });
    } catch (e) {
      debugPrint('Realtime Database streamHistoryItems notice: $e');
      return const Stream.empty();
    }
  }

  static bool _isSenderMatch(Map<String, dynamic> data, UserProfile user) {
    if (_isReceiverMatch(data, user)) {
      return false;
    }

    final userEmail = user.email.toLowerCase().trim();
    final senderEmail = (data['senderEmail'] as String? ?? '')
        .toLowerCase()
        .trim();
    final distEmail = (data['distributorEmail'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userEmail.isNotEmpty) {
      if (senderEmail == userEmail || distEmail == userEmail) return true;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final distId = (data['distributorId'] as String? ?? '').trim();
    final senderUid = (data['senderUid'] as String? ?? '').trim();
    if (currentUid != null && currentUid.isNotEmpty) {
      if (distId == currentUid || senderUid == currentUid) return true;
    }

    final userPrefix = userEmail.contains('@')
        ? userEmail.split('@').first
        : userEmail;
    if (userPrefix.isNotEmpty) {
      if ((distId.isNotEmpty && distId.toLowerCase() == userPrefix) ||
          (senderEmail.isNotEmpty && senderEmail.contains(userPrefix))) {
        return true;
      }
    }

    final userName = user.name.toLowerCase().trim();
    final userOrg = user.organization.toLowerCase().trim();
    final senderName = (data['senderName'] as String? ?? '')
        .toLowerCase()
        .trim();
    final distName = (data['distributorName'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userName.isNotEmpty &&
        (senderName == userName || distName == userName)) {
      return true;
    }
    if (userOrg.isNotEmpty && (senderName == userOrg || distName == userOrg)) {
      return true;
    }

    final userStore = user.storeLocation.toLowerCase().trim();
    final origin = (data['originLocation'] as String? ?? '')
        .toLowerCase()
        .trim();
    final senderLoc = (data['senderLocation'] as String? ?? '')
        .toLowerCase()
        .trim();
    final distLoc = (data['distributorLocation'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userStore.isNotEmpty && senderEmail.isEmpty) {
      if (origin == userStore ||
          senderLoc == userStore ||
          distLoc == userStore) {
        return true;
      }
    }

    return false;
  }

  static bool _isReceiverMatch(Map<String, dynamic> data, UserProfile user) {
    final userEmail = user.email.toLowerCase().trim();
    final receiverEmail = (data['receiverEmail'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userEmail.isNotEmpty &&
        receiverEmail.isNotEmpty &&
        receiverEmail == userEmail) {
      return true;
    }

    final userPrefix = userEmail.contains('@')
        ? userEmail.split('@').first
        : userEmail;
    final receiverDistId = (data['receiverDistributorId'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userPrefix.isNotEmpty &&
        receiverDistId.isNotEmpty &&
        (receiverDistId == userPrefix || receiverEmail.contains(userPrefix))) {
      return true;
    }

    final userStore = user.storeLocation.toLowerCase().trim();
    final dest = (data['destinationLocation'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (userStore.isNotEmpty && dest.isNotEmpty && dest == userStore) {
      return true;
    }

    final userName = user.name.toLowerCase().trim();
    final userOrg = user.organization.toLowerCase().trim();
    final receiverName = (data['receiverName'] as String? ?? '')
        .toLowerCase()
        .trim();
    if (receiverName.isNotEmpty &&
        ((userName.isNotEmpty && receiverName == userName) ||
            (userOrg.isNotEmpty && receiverName == userOrg))) {
      return true;
    }

    return false;
  }

  /// Saves or updates distributor user profile into Realtime Database `/users` and `/distributors`.
  Future<void> saveUserProfile(UserProfile profile, {String? uid}) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final docId =
          uid ??
          (profile.email.isNotEmpty
              ? profile.email.replaceAll('.', '_')
              : profile.name);
      final profileMap = <String, dynamic>{
        'name': profile.name,
        'organization': profile.organization,
        'location': profile.location,
        'email': profile.email,
        'role': 'distributor',
        'isDistributor': true,
        'storeLocation': profile.storeLocation,
        'latitude': profile.latitude,
        'longitude': profile.longitude,
        'phoneNumber': profile.phoneNumber,
        'accessRoleLabel': profile.accessRoleLabel,
        'permissionsDescription': profile.permissionsDescription,
        'updatedAt': ServerValue.timestamp,
      };
      if (uid != null) {
        profileMap['uid'] = uid;
      }

      await _db.ref('users/$docId').update(profileMap);

      final distributorMap = <String, dynamic>{
        'name': profile.name,
        'email': profile.email,
        'storeLocation': profile.storeLocation,
        'latitude': profile.latitude,
        'longitude': profile.longitude,
        'role': 'distributor',
        'isDistributor': true,
        'updatedAt': ServerValue.timestamp,
      };
      if (uid != null) {
        distributorMap['uid'] = uid;
      }

      await _db.ref('distributors/$docId').update(distributorMap);

      debugPrint(
        'Realtime Database: Distributor user profile ${profile.name} saved successfully.',
      );
    } catch (e) {
      debugPrint('Realtime Database saveUserProfile notice: $e');
    }
  }

  /// Realtime stream of tracking logs for a coolbox / batch
  Stream<List<Map<String, dynamic>>> streamCoolboxTrackingLogs(String batchId) {
    try {
      if (Firebase.apps.isEmpty || batchId.trim().isEmpty) {
        return const Stream.empty();
      }
      return _db.ref('dispatches/${batchId.trim()}/tracking_logs').onValue.map((
        event,
      ) {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];
        final map = _toMap(event.snapshot.value);
        final list = map.values.map((v) => _toMap(v)).toList();
        list.sort((a, b) {
          final aTime = a['timestamp'] is num ? a['timestamp'] as num : 0;
          final bTime = b['timestamp'] is num ? b['timestamp'] as num : 0;
          return aTime.compareTo(bTime);
        });
        return list;
      });
    } catch (e) {
      debugPrint('Realtime Database streamCoolboxTrackingLogs notice: $e');
      return const Stream.empty();
    }
  }
}

/// Backwards compatibility alias so all existing widgets seamlessly use Realtime Database
typedef FirestoreDispatchService = RealtimeDispatchService;
