import 'dart:convert';
// import 'package:prueba_de_entrega/src/services/database.dart';
import 'package:http/http.dart' as http;

class AuthService {

  Future<dynamic> login(String username, String password) async {
    String url = "https://appcer.4-72.com.co/AppSingle/api/Loginsipost";

    late String token = "Y2FybG9zLmdhbWJvYTpTYW50aWFnbzIwMjArKys=";
    late Map<String, String> headers;

    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Token': token
    };

    final uri = Uri.parse(url);
    final resp = await http.post(uri,
        body: {
          'Usuario': username,
          'Password': password,
        },
        headers: headers);
    final decodedData = json.decode(resp.body);
    return decodedData;




    // final uri = Uri.https(urlSipost, 'api/Loginsipost');
    // final resp = await http.post(uri,
    //     body: {'Cedula': username, 'Constraseña': password}, headers: headers);

    // final decodedData = json.decode(resp.body);
    // return decodedData;
  }
}
