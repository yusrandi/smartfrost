import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/smart_frost_logo.dart';
import '../../../dispatch/domain/models/location_coordinate.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/services/auth_session.dart';

/// Authentication Screen supporting both Login ("Masuk Akun")
/// and Local Registration ("Buat akun SMART-FROST") for Pengirim & Penerima roles.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.initialIsLogin = true});

  final bool initialIsLogin;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isLogin;
  final int _selectedRoleIndex = 0; // 0: Pengirim (Default distributor)
  bool _obscurePassword = true;
  bool _isLoading = false;

  double? _customLat = -4.8378;
  double? _customLng = 119.5372;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeLocationController = TextEditingController(
    text: 'Dermaga Maccini Baji',
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeLocationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final store = _storeLocationController.text.trim();

    setState(() => _errorMessage = null);

    if (!_isLogin && name.isEmpty) {
      setState(() => _errorMessage = 'Harap masukkan nama lengkap atau usaha.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Harap masukkan format email yang valid.');
      return;
    }

    if (password.length < 6) {
      setState(
        () => _errorMessage = 'Kata sandi minimal terdiri dari 6 karakter.',
      );
      return;
    }

    final resolvedStore = store.isNotEmpty ? store : 'Dermaga Maccini Baji';
    final coord = LocationCoordinate.resolve(resolvedStore);
    final lat = _customLat ?? coord.latitude;
    final lng = _customLng ?? coord.longitude;

    setState(() => _isLoading = true);

    try {
      // Authenticate with Firebase Auth in the background
      String? authUid;
      try {
        if (_isLogin) {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          authUid = cred.user?.uid;
        } else {
          final cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          await cred.user?.updateDisplayName(name);
          authUid = cred.user?.uid;
        }
      } on FirebaseAuthException catch (authEx) {
        String title = 'Gagal Masuk';
        String msg = authEx.message ?? 'Autentikasi gagal.';
        final code = authEx.code.toLowerCase();
        bool isInvalid = false;
        if (code == 'user-not-found' || code == 'error_user_not_found') {
          title = 'Akun Belum Terdaftar';
          msg =
              'Akun dengan email ini belum terdaftar di project baru. Silakan beralih ke tab Daftar untuk membuat akun.';
          isInvalid = true;
        } else if (code == 'wrong-password' ||
            code == 'error_wrong_password' ||
            code == 'invalid-credential' ||
            code == 'error_invalid_credential') {
          title = 'Kredensial Tidak Sesuai';
          msg =
              'Email atau kata sandi tidak sesuai (Invalid Credential). Jika Anda belum mendaftar di project Firebase ini, silakan buat akun pada tab Daftar.';
          isInvalid = true;
        } else if (code == 'email-already-in-use' ||
            code == 'error_email_already_in_use') {
          title = 'Email Sudah Terdaftar';
          msg =
              'Email ini sudah terdaftar. Silakan langsung masuk menggunakan kata sandi Anda.';
        } else if (code == 'weak-password') {
          title = 'Kata Sandi Terlalu Lemah';
          msg = 'Kata sandi minimal terdiri dari 6 karakter.';
        } else if (code == 'operation-not-allowed') {
          title = 'Konfigurasi Firebase';
          msg =
              'Provider Email/Password belum diaktifkan di Firebase Console project baru.';
        }
        if (mounted) {
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
          _showAuthAlertDialog(
            title: title,
            message: msg,
            isInvalidCredential: isInvalid,
          );
        }
        return;
      } on PlatformException catch (platEx) {
        String title = 'Gagal Masuk';
        String msg = platEx.message ?? 'Autentikasi gagal.';
        final code = platEx.code.toLowerCase();
        bool isInvalid = false;
        if (code.contains('user_not_found') ||
            code.contains('user-not-found')) {
          title = 'Akun Belum Terdaftar';
          msg =
              'Akun dengan email ini belum terdaftar di project baru. Silakan beralih ke tab Daftar untuk membuat akun.';
          isInvalid = true;
        } else if (code.contains('wrong_password') ||
            code.contains('wrong-password') ||
            code.contains('invalid_credential') ||
            code.contains('invalid-credential')) {
          title = 'Kredensial Tidak Sesuai';
          msg =
              'Email atau kata sandi tidak sesuai (Invalid Credential). Jika Anda belum mendaftar di project Firebase ini, silakan buat akun pada tab Daftar.';
          isInvalid = true;
        } else if (code.contains('email_already_in_use') ||
            code.contains('email-already-in-use')) {
          title = 'Email Sudah Terdaftar';
          msg =
              'Email ini sudah terdaftar. Silakan langsung masuk menggunakan kata sandi Anda.';
        } else if (code.contains('operation_not_allowed')) {
          title = 'Konfigurasi Firebase';
          msg =
              'Provider Email/Password belum diaktifkan di Firebase Console project baru.';
        }
        if (mounted) {
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
          _showAuthAlertDialog(
            title: title,
            message: msg,
            isInvalidCredential: isInvalid,
          );
        }
        return;
      } catch (_) {
        // Fallback gracefully if Firebase is offline or during tests
      }

      if (_isLogin) {
        await AuthSession.instance.login(
          email: email,
          password: password,
          roleIndex: _selectedRoleIndex,
          latitude: lat,
          longitude: lng,
          uid: authUid,
        );
      } else {
        AuthSession.instance.register(
          name: name,
          email: email,
          password: password,
          storeLocation: resolvedStore,
          roleIndex: _selectedRoleIndex,
          latitude: lat,
          longitude: lng,
          uid: authUid,
        );
      }

      // Navigate into main application hub
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(initialRoleIndex: _selectedRoleIndex),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _detectCurrentLocationForStore() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      setState(() {
        _customLat = pos.latitude;
        _customLng = pos.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Titik GPS toko terdeteksi: ${pos.latitude.toStringAsFixed(4)}°, ${pos.longitude.toStringAsFixed(4)}°',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  void _showAuthAlertDialog({
    required String title,
    required String message,
    bool isInvalidCredential = false,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                color: Color(0xFFDC2626),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.body.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF475569),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          if (isInvalidCredential)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isLogin = false;
                  _errorMessage = null;
                });
              },
              child: const Text(
                'Beralih ke Daftar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072435),
      body: Stack(
        children: [
          // 1. Deep Ocean Background Gradient with Decorative Waves
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF092A3D),
                    Color(0xFF0B465E),
                    Color(0xFF0E7A97),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Decorative Concentric Wave Rings in Background
          Positioned(
            top: 60,
            right: -60,
            child: CustomPaint(
              size: const Size(320, 320),
              painter: _OceanWaveRingPainter(),
            ),
          ),

          // 2. Scrollable Body Content
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomPadding = MediaQuery.paddingOf(context).bottom;
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // Brand Hero Header Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SmartFrost Brand Logo
                                const SmartFrostLogo(height: 38),
                                const SizedBox(height: 24),

                                // Section Overline
                                Text(
                                  'DISTRIBUSI IKAN ANTARPULAU',
                                  style: AppTypography.overline.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF67E8F9),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Main Catchphrase Headline
                                Text(
                                  'Rantai dingin yang\nlebih terpantau.',
                                  style: AppTypography.pageTitle.copyWith(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.18,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Supporting Description
                                Text(
                                  'Pantau suhu, telusuri perjalanan, dan catat serah terima ikan Kabupaten Pangkep dalam satu aplikasi.',
                                  style: AppTypography.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),

                          // 3. White Curved Bottom Sheet Container (Extends to bottom)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.lg,
                                AppSpacing.xl,
                                bottomPadding + AppSpacing.xxl,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 18,
                                    offset: Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Form Overline Badge
                                  Text(
                                    _isLogin
                                        ? 'MASUK AKUN'
                                        : 'REGISTRASI LOKAL',
                                    style: AppTypography.overline.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0284C7),
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Form Title
                                  Text(
                                    _isLogin
                                        ? 'Selamat datang kembali'
                                        : 'Buat akun SMART-FROST',
                                    style: AppTypography.pageTitle.copyWith(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Form Subtitle
                                  Text(
                                    'Kelola dan pantau pengiriman ikan Kabupaten Pangkep.',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Error Banner if validation fails
                                  if (_errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.sm,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFFCA5A5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.alertCircle,
                                            size: 16,
                                            color: Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFFB91C1C,
                                                    ),
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],

                                  // Registration Fields: Nama Lengkap & Lokasi Toko
                                  if (!_isLogin) ...[
                                    _AuthInputField(
                                      label: 'Nama lengkap / usaha',
                                      placeholder: 'Masukkan nama',
                                      controller: _nameController,
                                      keyboardType: TextInputType.text,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _AuthInputField(
                                      label: 'Lokasi toko / dermaga',
                                      placeholder:
                                          'Contoh: Dermaga Maccini Baji',
                                      controller: _storeLocationController,
                                      keyboardType: TextInputType.text,
                                      onChanged: (val) {
                                        final resolved =
                                            LocationCoordinate.resolve(val);
                                        setState(() {
                                          _customLat = resolved.latitude;
                                          _customLng = resolved.longitude;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.sm,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.mapPin,
                                            size: 13,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Koordinat Peta: ${_customLat?.toStringAsFixed(4) ?? "-4.8378"}°, ${_customLng?.toStringAsFixed(4) ?? "119.5372"}°',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap:
                                                _detectCurrentLocationForStore,
                                            child: Text(
                                              'Deteksi GPS',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(
                                                      0xFF0284C7,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],

                                  // Email Field
                                  _AuthInputField(
                                    label: 'Email',
                                    placeholder: 'nama@email.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  // Kata Sandi Field
                                  _AuthInputField(
                                    label: 'Kata sandi',
                                    placeholder: 'Minimal 6 karakter',
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    trailing: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? LucideIcons.eyeOff
                                            : LucideIcons.eye,
                                        size: 18,
                                        color: AppColors.textTertiary,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Primary Action Button (Masuk / Buat akun dan masuk)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _isLogin
                                                      ? 'Masuk'
                                                      : 'Buat akun dan masuk',
                                                  style: AppTypography.cardTitle
                                                      .copyWith(
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  LucideIcons.arrowRight,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Toggle Link (Daftar / Masuk)
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isLogin
                                              ? 'Belum punya akun? '
                                              : 'Sudah punya akun? ',
                                          style: AppTypography.body.copyWith(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                              _errorMessage = null;
                                            });
                                          },
                                          child: Text(
                                            _isLogin ? 'Daftar' : 'Masuk',
                                            style: AppTypography.body.copyWith(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Footer Attribution
                                  Center(
                                    child: Text(
                                      'SMART-FROST • Kabupaten Pangkajene dan Kepulauan',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 10,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Standardized Form Input Field for Auth
class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.trailing,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: AppTypography.body.copyWith(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: AppTypography.caption.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom Painter drawing concentric wave arcs in background
class _OceanWaveRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final center = Offset(size.width * 0.8, size.height * 0.2);
    canvas.drawCircle(center, 90, paint);
    canvas.drawCircle(center, 150, paint);
    canvas.drawCircle(center, 210, paint);
    canvas.drawCircle(center, 270, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
