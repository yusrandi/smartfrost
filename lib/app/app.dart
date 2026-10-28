import 'package:flutter/material.dart';

import '../features/auth/domain/services/auth_session.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import 'theme/app_theme.dart';

/// The root application widget for SmartFrost.
class SmartFrostApp extends StatelessWidget {
  const SmartFrostApp({
    super.key,
    this.initialHome,
  });

  final Widget? initialHome;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'SmartFrost',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: initialHome ??
              (AuthSession.instance.isLoggedIn
                  ? const HomePage()
                  : const AuthPage(initialIsLogin: true)),
        );
      },
    );
  }
}
