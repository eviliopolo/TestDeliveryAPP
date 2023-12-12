import 'package:flutter/material.dart';
// Screens
import 'package:LIQYAPP/src/screens/splash_screen.dart';
import 'package:LIQYAPP/src/screens/auth/login_screen.dart';
import 'package:LIQYAPP/src/screens/menu_screen.dart';
import 'package:LIQYAPP/src/screens/settings/settings_screen.dart';
import 'package:LIQYAPP/src/screens/resumen/historial_screen.dart';
import 'package:LIQYAPP/src/screens/modulo_otp/otp_screen.dart';
import 'package:LIQYAPP/src/screens/multientrega/edificio_screen.dart';
import 'package:LIQYAPP/src/screens/multientrega/multiscan_screen.dart';
import 'package:LIQYAPP/src/screens/modulo_scan/scan_barcode_screen.dart';
import 'package:LIQYAPP/src/screens/resumen/resumen_edificios_screen.dart';
import 'package:LIQYAPP/src/screens/resumen/resumen_entrega_edificio.dart';
import 'package:LIQYAPP/src/screens/modulo_scan/scan_module_screen.dart';
import 'package:LIQYAPP/src/screens/mail_americas/result_mail_americas.dart';
import 'package:LIQYAPP/src/screens/modulo_certificacion/certificar_screen.dart';
import 'package:LIQYAPP/src/screens/modulo_certificacion/certificar_firma_screen.dart';

final routes = {
  '/': (BuildContext context) => SplashScreen(),
  'login': (BuildContext context) => LoginScreen(),
  'menu': (BuildContext context) => MenuScreen(),
  'scan_module': (BuildContext context) => ScanModuleScreen(),
  'scan': (BuildContext context) => ScanBarcodeScreen(),
  'certificar_firma': (BuildContext context) => CertificarFirmaScreen(),
  'certificar': (BuildContext context) => CertificarScreen(),
  'settings': (BuildContext context) => SettingsScreen(),
  'historial': (BuildContext context) => HistorialScreen(),
  'otp': (BuildContext context) => OTPValidateScreen(),
  'edificio': (BuildContext context) => EdificioScreen(),
  'resumen_edificios': (BuildContext context) => ResumenEdificiosScreen(),
  'resumen_entrega_edificio': (BuildContext context) =>
      ResumenEntregaEdificioScreen(),
  'multiscan': (BuildContext context) => MultiScanScreen(),
  'result_ma': (BuildContext context) => ResultMailAmericasScreen(),
};
