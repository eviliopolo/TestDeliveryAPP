import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:LIQYAPP/src/services/geolocator_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';
//import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final _prefs = PreferenciasUsuario();
  final geo = GeolocatorService();
  bool _cargando = true;
  bool resultSettingsOpening = false;

  @override
  void initState() {
    super.initState();
    checkDevice();
  }

  checkDevice() async {
    bool isEnabled = await geo.isLocationServiceEnabled();

    if (!isEnabled) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('GPS Desactivado'),
              content: Text(
                  'Se requiere el uso del GPS para funcionar correctamente.'),
              actions: <Widget>[
                TextButton(
                  child: Text('ACTIVAR GPS'),
                  onPressed: () {
                    Navigator.pop(context);
                    openSettingsMenu();
                  },
                )
              ],
            );
          });
    } else {
      setState(() {
        _cargando = false;
      });

      _prefs.apiUrlBase = '5ntacto-dev.azurewebsites.net';
      //_prefs.apiUrlBase = '5ntacto-pro.azurewebsites.net';

      if (_prefs.logged) {
        Navigator.pushReplacementNamed(context, 'menu');
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    }
  }

  openSettingsMenu() async {
    try {
      await AppSettings.openAppSettings();
      resultSettingsOpening = true;
      pop();
    } catch (e) {
      resultSettingsOpening = false;
    }
  }

  static Future<void> pop({bool? animated}) async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop', animated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: Stack(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Text(
                  'Una marca registrada de',
                  style: TextStyle(color: yellow, fontSize: 10.0),
                ),
                SvgPicture.asset(
                  'assets/images/logo_spn_white.svg',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                SvgPicture.asset(
                  'assets/icons/logo-4-72.svg',
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                Visibility(
                  visible: _cargando,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 8.0),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8.0),
                      Text(
                        'Cargando, por favor espere...',
                        style: TextStyle(color: white),
                      )
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
