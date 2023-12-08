import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:prueba_de_entrega/app_config.dart';
import 'package:prueba_de_entrega/src/provider/ingreso_solidario_provider.dart';
import 'package:prueba_de_entrega/src/provider/multientrega_provider.dart';
import 'package:prueba_de_entrega/src/routes/routes.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/provider/data_sipost_provider.dart';
import 'package:prueba_de_entrega/src/services/connection_service.dart';
import 'package:prueba_de_entrega/src/services/scanner_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';

// State Management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferenciasUsuario();
  await prefs.initPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final prefs = PreferenciasUsuario();
    var config = AppConfig.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScanService>(
            create: (BuildContext context) => ScanService()),
        ChangeNotifierProvider<DataSipostProvider>(
            create: (BuildContext context) => DataSipostProvider()),
        ChangeNotifierProvider<IngresoSolidarioProvider>(
            create: (BuildContext context) => IngresoSolidarioProvider()),
        ChangeNotifierProvider<MultiEntregaProvider>(
            create: (BuildContext context) => MultiEntregaProvider()),
        StreamProvider<InternetConnectionStatus>.value(
          value: ConnectionService().connection,
          initialData: InternetConnectionStatus.disconnected,
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: config?.development ?? true,
          title: 'Prueba de entrega',
          theme: ThemeData(
            primaryColor: blue,
            secondaryHeaderColor: white,
            fontFamily: 'Medium',
          ),
          initialRoute: '/',
          routes: routes),
    );
  }
}
