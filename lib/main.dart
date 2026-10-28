import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/auth/domain/services/auth_session.dart';
import 'features/dispatch/data/services/firestore_master_data_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // On mobile (Android/iOS), the native SDK initializes [DEFAULT] via google-services.
      // Calling initializeApp() without options cleanly attaches Dart to the existing native app
      // without throwing [core/duplicate-app].
      await Firebase.initializeApp();
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    } else {
      debugPrint('Firebase initialization notice: $e');
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Sync session with active Firebase Auth user if present
  try {
    await AuthSession.instance.syncWithFirebaseAuth();
  } catch (e) {
    debugPrint('AuthSession sync notice: $e');
  }

  // Seed master data collections (coolbox, ikan, berat, distributor) if empty
  try {
    await FirestoreMasterDataService.instance.seedMasterDataIfNeeded();
  } catch (e) {
    debugPrint('MasterData seed notice: $e');
  }

  runApp(const SmartFrostApp());
}
