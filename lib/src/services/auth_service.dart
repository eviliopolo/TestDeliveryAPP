import 'dart:convert';
// import 'package:LIQYAPP/src/services/database.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<dynamic> login(String username, String password) async {
    String url = "https://svc1.sipost.co/AppSingle/api/Loginsipost";
    //String url = "https://appcer.4-72.com.co/AppSingle/api/Loginsipost";

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

    print('Response.Status ${resp.statusCode} ');
    print(' Response.Body ${resp.body} ');

    switch (resp.statusCode) {
      case 200:
        final decodedData = json.decode(resp.body);
        return decodedData;
      case 400:
        return null;
      case 401:
        return null;
      default:
        return null;
    }

    // final decodedData = json.decode(resp.body);
    // return decodedData;

    // final uri = Uri.https(urlSipost, 'api/Loginsipost');
    // final resp = await http.post(uri,
    //     body: {'Cedula': username, 'Constraseña': password}, headers: headers);

    // final decodedData = json.decode(resp.body);
    // return decodedData;
  }
}
