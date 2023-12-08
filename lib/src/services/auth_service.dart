import 'dart:convert';
import 'package:prueba_de_entrega/src/services/database.dart';
import 'package:http/http.dart' as http;

class AuthService extends Database {
  Future<dynamic> login(String username, String password) async {
    final uri = Uri.https(url, 'api/soporte/LoginApi');
    final resp = await http.post(uri,
        body: {'Cedula': username, 'Constraseña': password}, headers: headers);

    final decodedData = json.decode(resp.body);
    return decodedData;
  }
}
