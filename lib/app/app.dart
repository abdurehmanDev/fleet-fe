// ─── App Widget ───────────────────────────────────────────────────────────────
// Root MaterialApp with theme and router configuration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rangrej Fleet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
