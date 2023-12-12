import 'package:flutter/material.dart';
import 'package:LIQYAPP/app_config.dart';
import 'package:LIQYAPP/main.dart';
import 'package:LIQYAPP/src/services/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferenciasUsuario();
  await prefs.initPrefs();

  const configuredApp = AppConfig(
    development: true,
    child: MyApp(),
  );

  runApp(configuredApp);
}
