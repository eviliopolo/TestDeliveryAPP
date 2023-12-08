import 'package:flutter/material.dart';
import 'package:prueba_de_entrega/app_config.dart';
import 'package:prueba_de_entrega/main.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferenciasUsuario();
  await prefs.initPrefs();

  const configuredApp = AppConfig(
    development: false,
    child: MyApp(),
  );

  runApp(configuredApp);
}
