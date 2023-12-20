import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final _instancia = PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }
  PreferenciasUsuario._internal();

  late SharedPreferences _prefs;

  initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
  }
  //PreferenciasUsuario._internal();

  // URL BASE
  String get apiUrlBase {
    return _prefs.getString('apiUrlBase') ?? "5ntacto-dev.azurewebsites.net";
    //return _prefs.getString('apiUrlBase') ?? "5ntacto-pro.azurewebsites.net";
  }

  set apiUrlBase(String url) {
    _prefs.setString('apiUrlBase', url);
  }

  get cedulaMensajero {
    return _prefs.getString('cedulaMensajero') ?? "72245215";
  }

  get usuarioSipost {
    return _prefs.getString('usuarioSipost') ?? "72245215";
  }

  set cedulaMensajero(dynamic value) {
    _prefs.setString('cedulaMensajero', value);
  }

  set usuarioSipost(dynamic value) {
    _prefs.setString('usuarioSipost', value);
  }

  get logged {
    return _prefs.getBool('logged') ?? false;
  }

  set logged(dynamic value) {
    _prefs.setBool('logged', value);
  }

  // --- CONFIGURACIONES ---

  get lectorExterno {
    return _prefs.getBool('lectorExterno') ?? false;
  }

  set lectorExterno(dynamic value) {
    _prefs.setBool('lectorExterno', value);
  }

  get busquedaAuto {
    return _prefs.getBool('busquedaAuto') ?? true;
  }

  set busquedaAuto(dynamic value) {
    _prefs.setBool('busquedaAuto', value);
  }

  get individual {
    return _prefs.getBool('individual') ?? true;
  }

  set individual(dynamic value) {
    _prefs.setBool('individual', value);
  }

  get multiple {
    return _prefs.getBool('multiple') ?? true;
  }

  set multiple(dynamic value) {
    _prefs.setBool('multiple', value);
  }

  get ingresoSolidario {
    return _prefs.getBool('ingresoSolidario') ?? false;
  }

  set ingresoSolidario(dynamic value) {
    _prefs.setBool('ingresoSolidario', value);
  }

  get mailAmericas {
    return _prefs.getBool('mailAmericas') ?? false;
  }

  set mailAmericas(dynamic value) {
    _prefs.setBool('mailAmericas', value);
  }
}
