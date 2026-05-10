// ─── Main Entry Point ─────────────────────────────────────────────────────────
// App bootstrap: init dependencies, load env, run app
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rangrej_fleet/app/app.dart';
import 'package:rangrej_fleet/core/di/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Setup dependency injection
  await setupDependencies();

  runApp(const App());
}
