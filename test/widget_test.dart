import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smartfrost/app/app.dart';
import 'package:smartfrost/core/widgets/smart_qr_scanner_sheet.dart';
import 'package:smartfrost/features/auth/domain/services/auth_session.dart';
import 'package:smartfrost/features/auth/presentation/pages/auth_page.dart';

void main() {
  setUp(() async {
    await AuthSession.instance.login(
      email: 'sasa@smartfrost.id',
      password: 'password',
      name: 'sasa',
      organization: 'Bahari Sejahtera',
      storeLocation: 'Dermaga Maccini Baji',
      roleIndex: 0,
    );
  });
  testWidgets(
    'SmartFrost unified navigation and History module test for both roles',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // 1. Initial State: Beranda - Pengiriman
      expect(find.text('DA'), findsOneWidget);
      expect(find.text('DISTRIBUTOR A'), findsNothing);
      expect(find.text('DISTRIBUTOR B'), findsNothing);
      expect(find.textContaining('Bahari.'), findsOneWidget);

      // 2. Navigate to Riwayat via bottom navigation bar
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Verify Riwayat Pengiriman
      expect(find.text('Riwayat pengiriman'), findsOneWidget);
      expect(find.text('2 batch tersimpan di perangkat ini.'), findsOneWidget);
      expect(find.text('Cari ID batch, ikan, atau lokasi...'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);

      // Verify Sea Route in Dispatch History Card
      expect(
        find.text('Dermaga Maccini Baji → Pulau Jangang-Jangangan'),
        findsOneWidget,
      );
      expect(
        find.text('Pulau Balang Lompo → Pelabuhan Maccini Baji'),
        findsOneWidget,
      );

      // 3. Toggle role in History to Penerimaan
      await tester.tap(find.text('Penerimaan'));
      await tester.pumpAndSettle();

      // Verify Riwayat Penerimaan
      expect(find.text('DISTRIBUTOR B'), findsNothing);
      expect(find.text('Riwayat penerimaan'), findsOneWidget);

      // Verify Supplier in Receiving History Card
      expect(find.text('Bahari Sejahtera'), findsWidgets);

      // Verify bottom bar has no 'Profil' tab, perfectly balanced with 3 items
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Profil'), findsNothing);

      // 4. Navigate to Profil via Top Header Avatar ('DB')
      await tester.tap(find.text('DB'));
      await tester.pumpAndSettle();

      // Verify Profile Page Elements
      expect(find.text('AKUN'), findsOneWidget);
      expect(find.text('Profil pengguna'), findsOneWidget);
      expect(find.text('sasa'), findsOneWidget);
      expect(find.text('Informasi akun'), findsOneWidget);
      expect(find.text('Role dan identitas pengguna'), findsOneWidget);
      expect(find.text('Status sinkronisasi'), findsOneWidget);
      expect(find.text('Online • data dapat disinkronkan'), findsOneWidget);
      expect(find.text('Hak akses'), findsOneWidget);
      expect(find.text('Keluar dari akun'), findsOneWidget);
      expect(find.text('Kembali ke pilihan role'), findsOneWidget);
      expect(find.text('Versi demonstrasi'), findsOneWidget);
      expect(
        find.text(
          'Autentikasi dan data memakai penyimpanan lokal browser. Hubungkan backend sebelum penggunaan operasional.',
        ),
        findsOneWidget,
      );

      // 5. Return back from Profile using back button
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      // 6. Return to Beranda tab
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();

      expect(find.text('Penerimaan ikan'), findsOneWidget);
      expect(find.text('DISTRIBUTOR B'), findsNothing);
    },
  );

  testWidgets('SmartFrost New Dispatch 3-step wizard flow test', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SmartFrostApp());
    await tester.pumpAndSettle();

    // Tap hot prominent button "Kirim" on bottom bar
    await tester.tap(find.text('Kirim'));
    await tester.pumpAndSettle();

    // 1. Verify Step 1: Scan QR coolbox
    expect(find.text('Pengiriman baru'), findsOneWidget);
    expect(find.text('Coolbox'), findsOneWidget);
    expect(find.text('Data ikan'), findsOneWidget);
    expect(find.text('Konfirmasi'), findsOneWidget);
    expect(find.text('Scan QR coolbox'), findsOneWidget);
    expect(find.text('Kamera belum aktif'), findsOneWidget);
    expect(find.text('Aktifkan kamera'), findsOneWidget);
    expect(find.text('SFR-CB-042'), findsOneWidget);

    // Advance to Step 2
    final lanjutBtn = find.text('Lanjutkan');
    await tester.ensureVisible(lanjutBtn);
    await tester.tap(lanjutBtn);
    await tester.pumpAndSettle();

    // 2. Verify Step 2: Data muatan Initial Placeholders
    expect(find.text('Data muatan'), findsOneWidget);
    expect(find.text('Pilih jenis ikan'), findsOneWidget);
    expect(find.text('Pilih berat ikan'), findsOneWidget);
    expect(find.text('Dermaga Maccini Baji'), findsWidgets);
    expect(
      find.text('Lokasi toko/dermaga distributor Anda (terisi otomatis)'),
      findsOneWidget,
    );
    expect(find.text('Pilih distributor tujuan'), findsOneWidget);
    expect(find.text('Belum memilih distributor tujuan'), findsOneWidget);
    expect(
      find.text(
        'Data suhu dan GPS hanya akan ditampilkan jika perangkat sensor terhubung. Aplikasi tidak membuat data sensor simulasi.',
      ),
      findsOneWidget,
    );

    // Attempt to proceed without filling fields -> verify validation rejection
    final tinjauBtn = find.text('Tinjau data');
    await tester.ensureVisible(tinjauBtn);
    await tester.tap(tinjauBtn);
    await tester.pumpAndSettle();

    expect(find.text('Harap pilih jenis ikan'), findsOneWidget);
    expect(find.text('Harap pilih berat ikan'), findsOneWidget);
    expect(find.text('Harap pilih distributor tujuan'), findsOneWidget);
    expect(
      find.text('Mohon lengkapi seluruh data muatan sebelum melanjutkan.'),
      findsOneWidget,
    );
    expect(find.text('Konfirmasi pengiriman'), findsNothing);

    // Fill each required field
    final jenisIkanFinder = find.text('Pilih jenis ikan');
    await tester.ensureVisible(jenisIkanFinder);
    await tester.tap(jenisIkanFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ikan Bandeng').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    final beratFinder = find.text('Pilih berat ikan');
    await tester.ensureVisible(beratFinder);
    await tester.tap(beratFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('80 - 90 kg').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    // Lokasi awal is already filled with distributor store location
    expect(find.text('Dermaga Maccini Baji'), findsWidgets);

    final distFinder = find.text('Pilih distributor tujuan');
    await tester.ensureVisible(distFinder);
    await tester.tap(distFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Pulau Jangan-Jangangan (Pulau Jangan-Jangangan)').last,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Pulau Jangan-Jangangan'), findsWidgets);

    // Advance to Step 3 after full validation pass
    await tester.ensureVisible(tinjauBtn);
    await tester.tap(tinjauBtn);
    await tester.pumpAndSettle();

    // 3. Verify Step 3: Konfirmasi pengiriman
    expect(find.text('Konfirmasi pengiriman'), findsOneWidget);
    expect(find.textContaining('SFR-CB042'), findsOneWidget);
    expect(find.text('Pengirim'), findsOneWidget);
    expect(find.text('Bahari Sejahtera'), findsWidgets);
    expect(find.text('Ikan Bandeng • 80 - 90 kg'), findsOneWidget);
    expect(
      find.text('Dermaga Maccini Baji → Pulau Jangan-Jangangan'),
      findsOneWidget,
    );
    expect(find.text('SENSOR SUHU'), findsOneWidget);
    expect(find.text('Riwayat suhu'), findsOneWidget);
    expect(find.text('Menunggu data sensor'), findsOneWidget);
    expect(find.text('FROSTSCORE'), findsOneWidget);
    expect(find.text('Belum dapat dihitung'), findsOneWidget);
    expect(find.text('Ubah data'), findsOneWidget);
    expect(find.text('Konfirmasi kirim'), findsOneWidget);

    // Confirm dispatch
    final konfirmBtn = find.text('Konfirmasi kirim');
    await tester.ensureVisible(konfirmBtn);
    await tester.tap(konfirmBtn);
    await tester.pumpAndSettle();

    // 4. Verify Live Tracking Page (Pelacakan Pengiriman)
    expect(find.text('Pelacakan pengiriman'), findsOneWidget);
    expect(find.textContaining('SFR-CB042'), findsWidgets);
    expect(find.text('Sedang berjalan'), findsOneWidget);
    expect(find.text('PELACAKAN PERJALANAN'), findsOneWidget);
    expect(find.text('Menunggu GPS'), findsOneWidget);
    expect(find.text('Lokasi GPS real-time'), findsOneWidget);
    expect(find.text('Dermaga Maccini Baji'), findsWidgets);
    expect(find.text('Pulau Jangan-Jangangan'), findsWidgets);
    expect(find.text('Koordinat GPS belum diterima'), findsOneWidget);
    expect(find.text('Jarak real-time'), findsOneWidget);
    expect(find.text('— km'), findsOneWidget);
    expect(find.text('Pembaruan terakhir'), findsOneWidget);
    expect(find.text('Belum tersedia'), findsOneWidget);
    expect(
      find.text(
        'Jarak hanya dihitung dari koordinat GPS nyata; aplikasi tidak membuat lokasi simulasi.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'FrostScore adalah indikator risiko rantai dingin, bukan hasil laboratorium atau sertifikat keamanan pangan.',
      ),
      findsOneWidget,
    );

    // Return to Beranda from Tracking Page via AppBar back button
    await tester.tap(find.byIcon(LucideIcons.arrowLeft).first);
    await tester.pumpAndSettle();

    // Back on Beranda
    expect(find.textContaining('Bahari.'), findsOneWidget);
  });

  testWidgets('SmartFrost AuthPage login and registration flow test', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Pump app with initialHome set to AuthPage
    await tester.pumpWidget(
      const SmartFrostApp(
        initialHome: AuthPage(initialIsLogin: true),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Login Screen UI elements (Image 1)
    expect(find.text('DISTRIBUSI IKAN ANTARPULAU'), findsOneWidget);
    expect(find.text('Rantai dingin yang\nlebih terpantau.'), findsOneWidget);
    expect(
      find.text(
        'Pantau suhu, telusuri perjalanan, dan catat serah terima ikan Kabupaten Pangkep dalam satu aplikasi.',
      ),
      findsOneWidget,
    );
    expect(find.text('MASUK AKUN'), findsOneWidget);
    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(
      find.text('Kelola dan pantau pengiriman ikan Kabupaten Pangkep.'),
      findsOneWidget,
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets); // Button and toggle link
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    expect(
      find.text('SMART-FROST • Kabupaten Pangkajene dan Kepulauan'),
      findsOneWidget,
    );

    // 2. Switch to Registration Screen (Image 2)
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('REGISTRASI LOKAL'), findsOneWidget);
    expect(find.text('Buat akun SMART-FROST'), findsOneWidget);
    expect(find.text('Nama lengkap / usaha'), findsOneWidget);
    expect(find.text('Lokasi toko / dermaga'), findsOneWidget);
    expect(find.text('Buat akun dan masuk'), findsOneWidget);
    expect(find.text('Sudah punya akun? '), findsOneWidget);

    // Fill in registration form as new distributor
    final nameField = find.widgetWithText(TextField, 'Masukkan nama');
    await tester.enterText(nameField, 'CV Berkah Laut Pangkep');

    final storeField = find.widgetWithText(
      TextField,
      'Dermaga Maccini Baji',
    );
    await tester.enterText(storeField, 'Dermaga Maccini Baji Pintu 2');

    final emailField = find.widgetWithText(TextField, 'nama@email.com');
    await tester.enterText(emailField, 'berkah@pangkep.id');

    final passwordField = find.widgetWithText(
      TextField,
      'Minimal 6 karakter',
    );
    await tester.enterText(passwordField, 'pangkep123');
    await tester.pumpAndSettle();

    // Submit registration
    await tester.tap(find.text('Buat akun dan masuk'));
    await tester.pumpAndSettle();

    // 3. Verify user is registered and logged into HomePage
    expect(find.text('Pengiriman'), findsOneWidget);
    expect(find.text('Penerimaan'), findsOneWidget);
  });

  testWidgets(
    'SmartFrost selecting target distributor auto-fills receiver name and destination location',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim'));
      await tester.pumpAndSettle();

      // Proceed past coolbox step
      final lanjutBtn = find.text('Lanjutkan');
      await tester.ensureVisible(lanjutBtn);
      await tester.tap(lanjutBtn);
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Distributor tujuan'), findsOneWidget);
      expect(find.text('Pilih distributor tujuan'), findsOneWidget);
      expect(find.text('Belum memilih distributor tujuan'), findsOneWidget);

      // Select target distributor: Pulau Karanrang (Pulau Karanrang)
      final distFinder = find.text('Pilih distributor tujuan');
      await tester.ensureVisible(distFinder);
      await tester.tap(distFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Pulau Karanrang (Pulau Karanrang)').last,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Verify that destination and receiver are now automatically populated!
      expect(find.text('Pulau Karanrang'), findsWidgets);
      expect(
        find.text('Tujuan: Pulau Karanrang (terisi otomatis)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SmartFrost seeds and displays the new 6 island distributor accounts in dispatch form',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim'));
      await tester.pumpAndSettle();

      // Proceed past coolbox step
      final lanjutBtn = find.text('Lanjutkan');
      await tester.ensureVisible(lanjutBtn);
      await tester.tap(lanjutBtn);
      await tester.pumpAndSettle();

      // Tap target distributor dropdown
      final distFinder = find.text('Pilih distributor tujuan');
      await tester.ensureVisible(distFinder);
      await tester.tap(distFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify each of the 6 distributors is present in the options
      expect(
        find.text('Dermaga Biringkassi (Dermaga Biringkassi)'),
        findsWidgets,
      );
      expect(find.text('Pulau Karanrang (Pulau Karanrang)'), findsWidgets);
      expect(find.text('Pulau Sanane (Pulau Sanane)'), findsWidgets);
      expect(
        find.text('Pulau Jangan-Jangangan (Pulau Jangan-Jangangan)'),
        findsWidgets,
      );
      expect(find.text('Pulau Kalupu (Pulau Kalupu)'), findsWidgets);
      expect(find.text('Pulau Kapoposang (Pulau Kapoposang)'), findsWidgets);

      // Select Pulau Kapoposang
      await tester.tap(
        find.text('Pulau Kapoposang (Pulau Kapoposang)').last,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Verify auto-fill of destination location & receiver name
      expect(find.text('Pulau Kapoposang'), findsWidgets);
      expect(
        find.text('Tujuan: Pulau Kapoposang (terisi otomatis)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SmartFrost Profile logout clears session and navigates to AuthPage',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 1. Start on HomePage with active session
      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // 2. Open Profile page via header avatar ('CB', 'DA', or 'DB')
      final avatarFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == 'CB' ||
                widget.data == 'DA' ||
                widget.data == 'DB'),
      );
      expect(avatarFinder, findsOneWidget);
      await tester.tap(avatarFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Profil pengguna'), findsOneWidget);
      expect(find.text('Keluar dari akun'), findsOneWidget);

      // 3. Tap 'Keluar dari akun'
      await tester.ensureVisible(find.text('Keluar dari akun'));
      await tester.tap(find.text('Keluar dari akun'));
      await tester.pumpAndSettle();

      // 4. Verify session is cleared and AuthPage is displayed
      expect(AuthSession.instance.isLoggedIn, isFalse);
      expect(AuthSession.instance.currentUser, isNull);
      expect(find.text('MASUK AKUN'), findsOneWidget);
      expect(find.text('Selamat datang kembali'), findsOneWidget);
    },
  );

  testWidgets(
    'SmartQrScannerSheet displays manual coolbox ID selection option and returns chosen ID',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      String? resultId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultId = await SmartQrScannerSheet.show(
                    context,
                    title: 'Scan QR Penerimaan',
                    subtitle: 'Pindai barcode pada coolbox atau pilih ID coolbox yang tiba',
                    coolboxOptions: const ['SFR-KK-201', 'SFR-CB-01', 'SFR-SN-301'],
                    initialCoolboxId: 'SFR-KK-201',
                  );
                },
                child: const Text('Open Scanner'),
              ),
            ),
          ),
        ),
      );

      // Open scanner sheet
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Verify Scanner UI elements
      expect(find.text('Scan QR Penerimaan'), findsOneWidget);
      expect(
        find.text('Pindai barcode pada coolbox atau pilih ID coolbox yang tiba'),
        findsOneWidget,
      );
      expect(find.text('atau pilih ID coolbox secara manual'), findsOneWidget);
      expect(find.text('ID Coolbox'), findsOneWidget);
      expect(find.text('Pilih jika QR tidak dapat dipindai'), findsOneWidget);
      expect(find.text('Pilih ID Coolbox Ini'), findsOneWidget);

      // Select 'Pilih ID Coolbox Ini'
      await tester.tap(find.text('Pilih ID Coolbox Ini'));
      await tester.pumpAndSettle();

      // Verify sheet is popped and returned selected coolbox ID
      expect(resultId, equals('SFR-KK-201'));
    },
  );

  testWidgets(
    'Tapping batch card in Perlu diperiksa navigates directly to ReceivingDetailPage without scanner',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Ensure logged in session for test
      await AuthSession.instance.login(
        email: 'sasa@smartfrost.id',
        password: 'password',
      );

      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // Switch to Penerimaan role in HomePage
      await tester.tap(find.text('Penerimaan'));
      await tester.pumpAndSettle();

      // Find card in "Perlu diperiksa"
      expect(find.text('Perlu diperiksa'), findsOneWidget);
      expect(find.text('SFR-PKP-240601'), findsOneWidget);

      // Tap on the batch card
      await tester.tap(find.text('SFR-PKP-240601'));
      await tester.pumpAndSettle();

      // Verify it navigated directly to ReceivingDetailPage (Detail batch penerimaan)
      expect(find.text('Detail batch penerimaan'), findsOneWidget);
      expect(find.text('SFR-PKP-240601'), findsOneWidget);
      expect(find.text('Riwayat suhu'), findsOneWidget);
      expect(find.text('Keputusan penerimaan'), findsOneWidget);
      expect(find.text('Terima'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);

      // Verify Scanner sheet was NOT opened
      expect(find.text('atau pilih ID coolbox secara manual'), findsNothing);
    },
  );

  testWidgets(
    'Receiving scanner validates coolbox ID and displays warning if not in receiving list',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Log in as a distributor with no incoming mock shipments
      await AuthSession.instance.login(
        email: 'biringkassi@gmail.com',
        password: 'password',
      );

      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // Switch to Penerimaan
      await tester.tap(find.text('Penerimaan'));
      await tester.pumpAndSettle();

      // Tap on the scan button in ReceivingHeroCard
      await tester.tap(find.text('Scan QR penerimaan'));
      await tester.pumpAndSettle();

      // QR Scanner sheet should open with coolbox selection section
      expect(find.text('Scan QR Penerimaan'), findsOneWidget);
      expect(find.text('atau pilih ID coolbox secara manual'), findsOneWidget);

      // Since biringkassi has no incoming coolboxes in test Firestore, empty notice should be shown
      expect(
        find.text(
          'Tidak ada coolbox dalam pengiriman menuju lokasi Anda saat ini.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'ReceivingDetailPage interactive inline flow for Tolak and Terima',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await AuthSession.instance.login(
        email: 'sasa@smartfrost.id',
        password: 'password',
      );

      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // Go to Penerimaan and open detail
      await tester.tap(find.text('Penerimaan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SFR-PKP-240601'));
      await tester.pumpAndSettle();

      // Scroll down to Keputusan penerimaan card
      final decisionCard = find.text('Keputusan penerimaan');
      await tester.ensureVisible(decisionCard);
      await tester.pumpAndSettle();

      // Verify initial state: Tolak and Terima buttons
      expect(find.text('Tolak'), findsOneWidget);
      expect(find.text('Terima'), findsOneWidget);

      // 1. Test TERIMA flow
      await tester.tap(find.text('Terima'));
      await tester.pumpAndSettle();

      expect(find.text('Terima coolbox SFR-PKP-240601?'), findsOneWidget);
      expect(
        find.text('Keputusan akan tersimpan bersama waktu transaksi.'),
        findsOneWidget,
      );
      expect(find.text('Simpan keputusan'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Back to initial buttons
      expect(find.text('Tolak'), findsOneWidget);
      expect(find.text('Terima'), findsOneWidget);

      // 2. Test TOLAK flow
      await tester.ensureVisible(find.text('Tolak'));
      await tester.tap(find.text('Tolak'));
      await tester.pumpAndSettle();

      expect(find.text('Tolak coolbox SFR-PKP-240601?'), findsOneWidget);
      expect(find.text('Alasan penolakan'), findsOneWidget);
      expect(
        find.text('Jelaskan kondisi ikan atau kendala lainnya'),
        findsOneWidget,
      );
      expect(find.text('Simpan keputusan'), findsOneWidget);

      // Tap Batal
      final batalBtn = find.text('Batal');
      await tester.ensureVisible(batalBtn);
      await tester.tap(batalBtn);
      await tester.pumpAndSettle();

      expect(find.text('Tolak'), findsOneWidget);
      expect(find.text('Terima'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileDetailPage displays comprehensive distributor details and navigates from ProfilePage',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SmartFrostApp());
      await tester.pumpAndSettle();

      // Navigate to Profile from header avatar
      await tester.tap(find.text('DA'));
      await tester.pumpAndSettle();

      // Tap 'Informasi akun'
      expect(find.text('Informasi akun'), findsOneWidget);
      await tester.tap(find.text('Informasi akun'));
      await tester.pumpAndSettle();

      // Verify ProfileDetailPage content
      expect(find.text('Informasi Akun Distributor'), findsOneWidget);
      expect(find.text('Distributor Aktif'), findsOneWidget);
      expect(find.text('Identitas & Kontak'), findsOneWidget);
      expect(find.text('Pangkalan & Wilayah Operasional'), findsOneWidget);
      expect(find.text('Wewenang & Rantai Dingin'), findsOneWidget);
      expect(find.text('Ubah Informasi Profil'), findsOneWidget);

      // Verify back navigation
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(find.text('Profil pengguna'), findsOneWidget);
    },
  );
}


