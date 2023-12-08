import 'package:prueba_de_entrega/src/services/prefs.dart';

abstract class Database {
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  late String _url;
  late String _token;
  late Map<String, String> _headers;

  Database() {
    _url = prefs.apiUrlBase;
    _token = "aLkjasd789472**==";
    _headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Token': _token
    };
  }

  String get url => _url;
  String get token => _token;
  Map<String, String> get headers => _headers;
}
